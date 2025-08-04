#ifndef _CNF_GEN_HPP
#define _CNF_GEN_HPP

#include <iostream>
#include <sstream>
#include <cassert>
#include <vector>

template<typename T>
struct Span {
	const T* first;
	size_t size;

	Span(const T* first, size_t size) : first(first), size(size) {}
	Span(const std::vector<T>& vec) {
		first = vec.data();
		size = vec.size();
	}

	const T* begin() { return first; }
	const T* end() { return first + size; }

	const T& operator[](size_t i) { return *(first + i); }
};

template<typename T>
Span<T> subSpan(Span<T> s, int start, int length) {
	return Span<T>(s.first + start, length);
}

template<typename T>
std::vector<T> iotaCountSpan(T start, T count) { 
	std::vector<T> vec(count);
	for(T i = 0; i < count; i++)
		vec[i] = start + i;
	return vec;
}

template<typename F, typename T, typename... Ts>
void callWithSpanImpl(F func, std::vector<T>&& acc, Span<T> head, Ts... tail) {
	acc.insert(acc.end(), head.begin(), head.end());
	callWithSpanImpl(func, std::move(acc), tail...);
}
template<typename F, typename T, typename... Ts>
void callWithSpanImpl(F func, std::vector<T>&& acc, const std::vector<T>& head, Ts... tail) {
	acc.insert(acc.end(), head.begin(), head.end());
	callWithSpanImpl(func, std::move(acc), tail...);
}
template<typename F, typename T, typename... Ts>
void callWithSpanImpl(F func, std::vector<T>&& acc, T head, Ts... tail) {
	acc.push_back(head);
	callWithSpanImpl(func, std::move(acc), tail...);
}
template<typename F, typename T>
void callWithSpanImpl(F func, std::vector<T>&& acc) {
	func(Span<T>(acc));
}

template<typename F, typename T> void callWithSpan(F func, Span<T> head) {
	func(head);
}
template<typename F, typename T> void callWithSpan(F func, const std::vector<T>& head) {
	func(Span<T>(head));
}
template<typename F, typename T> void callWithSpan(F func, T head)
{
	std::vector<T> vec { head };
	func(Span<T>(vec));
}

template<typename F, typename T, typename... Ts>
void callWithSpan(F func, T head, Ts... tail) {
	callWithSpanImpl(func, std::vector<T>(), head, tail...);
}
template<typename F, typename T, typename... Ts>
void callWithSpan(F func, const std::vector<T>& head, Ts... tail) {
	callWithSpanImpl(func, std::vector<T>(), head, tail...);
}
template<typename F, typename T, typename... Ts>
void callWithSpan(F func, Span<T> head, Ts... tail) {
	callWithSpanImpl(func, std::vector<T>(), head, tail...);
}

struct CNFGen {

	bool comments = true;
	void disableComments() { comments = false; }

	using Var = int;
	Var varCount = 1; // first variable 1, 0 is reserved for end of clause
	int clauseCount = 0;

	std::stringstream out;

	char dimspecType;
	CNFGen(char dimspecType = 'p') : dimspecType(dimspecType) {}

	void writeToStdCout() {
		std::cout << dimspecType << " cnf " << varCount - 1 << " " << clauseCount << '\n';
		std::cout << out.str() << std::flush;
	}

	template<typename... T>
	void printClause(T... vars) {
		callWithSpan([this](Span<Var> vars) { 
			for(const Var v : vars) out << v << " ";
			out << "0\n";
		}, vars...);
		clauseCount++;
	}

	template<typename... T>
	void printNaiveAtMostOne(T... vars) {
		callWithSpan([this](Span<Var> vars) {
			for(size_t i = 0; i < vars.size; i++)
				for(size_t j = i+1; j < vars.size; j++)
					printClause(-vars[i], -vars[j]);
		}, vars...);
	}

	template<typename... T>
	void printNaiveAtMostOneWithImplication(int implyingVar, T... vars) {
		callWithSpan([this, implyingVar](Span<Var> vars) {
			for(size_t i = 0; i < vars.size; i++)
				for(size_t j = i+1; j < vars.size; j++)
					printClause(-implyingVar, -vars[i], -vars[j]);
		}, vars...);
	}

	int addVariables(int count) {
		if(comments) out << "c add " << count << " variables\n";
		int vars = this->varCount;
		this->varCount += count;
		return vars;
	}

	int addVariablesOneHot(int count, int optionCount) {
		if(comments) out << "c add " << count << " variables with " << optionCount << " options using one-hot encoding.\n";
		int vars = this->varCount;
		this->varCount += count * optionCount;
		return vars;
	}

	void addAtLeastOneConstraint(int vars, int count, int optionCount) {
		if(comments) out << "c at least one constraint\n";
		for(int c = 0; c < count; c++)
			printClause(iotaCountSpan(vars + c * optionCount, optionCount));
	}
	void addAtLeastOneConstraint(Span<int> vars) {
		printClause(vars);
	}

	void addAtMostOneConstraintNaive(int vars, int count, int optionCount) {
		if(comments) out << "c naive at most one constraint\n";
		for(int c = 0; c < count; c++)
			printNaiveAtMostOne(iotaCountSpan(vars + c * optionCount, optionCount));
	}
	void addAtMostOneConstraintNaive(Span<int> vars) {
		printNaiveAtMostOne(vars);
	}
	void addAtMostOneConstraintNaive(Span<int> vars, int implyingVar) {
		printNaiveAtMostOneWithImplication(implyingVar, vars);
	}

	void addAtMostOneConstraintCommander(int vars, int count, int optionsCount, int groupSize) {
		if(comments) out << "c commander at most one constraint\n";
		for(int c = 0; c < count; c++)
			addAtMostOneConstraintCommander(iotaCountSpan(vars + c * optionsCount, optionsCount), groupSize);
	}

	void addAtMostOneConstraintCommander(Span<int> vars, int groupSize) {
		assert(vars.size % groupSize == 0);

		int groupCount = vars.size / groupSize;

		int commanderVars = this->varCount;
		this->varCount += groupCount;

		// at least one commander
		printClause(iotaCountSpan(commanderVars, groupCount));

		// at most one commander
		printNaiveAtMostOne(iotaCountSpan(commanderVars, groupCount));

		// at least one in group
		for(int g = 0; g < groupCount; g++)
			printClause(-(commanderVars + g), subSpan(vars, g * groupSize, groupSize));

		// at most one in group
		for(int g = 0; g < groupCount; g++)
			printNaiveAtMostOne(-(commanderVars + g), subSpan(vars, g * groupSize, groupSize));
	}

	void addAtMostOneConstraintLadder(int vars, int count, int optionCount) {
		for(int c = 0; c < count; c++)
			addAtMostOneConstraintLadder(iotaCountSpan(vars + c * optionCount, optionCount));
	}

	void addAtMostOneConstraintLadder(Span<int> vars) {
		int ladderVars = this->varCount;
		this->varCount += vars.size - 1;

		// variable implies ladder variable
		for(int i = 0; i < vars.size - 1; i++)
			printClause(-vars[i], ladderVars + i);

		// ladder var implies next ladder var
		for(int i = 0; i < vars.size - 2; i++)
			printClause(-(ladderVars + i), ladderVars + i + 1);
		
		// ladder var inplies not next variable
		for(int i = 0; i < vars.size - 1; i++)
			printClause(-(ladderVars + i), -vars[i+1]);
	}

	static int getNumBitsForOptions(int optionCount) {
		int numbits = 1;
		int temp = optionCount - 1;
		while(temp >>= 1) numbits++;
		return numbits;
	}

	int addVariablesExactlyOneBinary(int count, int optionCount) {
		assert(optionCount >= 1);
		if(comments)
			out << "c " << count << " vars added with " << optionCount << " options"
				<< " with exactly one constraint using the binary encoding\n";
		
		int numbits = getNumBitsForOptions(optionCount);
		if(comments) out << "c use " << numbits << " bits per var\n";

		int vars = varCount;
		this->varCount += count * numbits;
		if(comments) out << "c " << "vars : [" << vars << "," << this->varCount-1 << "]\n";

		if((1<<numbits) == optionCount) {
			if(comments) out << "c exatly 2^n options. do nothing.\n";
		} else {
			if(comments) out << "c disallow invalid values explicitly\n";
			for(int c = 0; c < count; c++) {
				for(int v = optionCount; v < (1<<numbits); v++) {
					std::vector<int> clause;

					for(int i = 0; i < numbits; i++) {
						int var = vars + c * numbits + i;
						if(v & (1<<i)) var = -var;
						clause.push_back(var);
					}

					printClause(clause);
				}
			}
		}

		if(comments) out << "c\n";
		return vars;
	}
	
	
};

#endif
