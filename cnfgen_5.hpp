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
Span<T> subSpan(const Span<T> s, int start, int length) {
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
		std::cout << dimspecType << " cnf " << varCount - 1 << " " << clauseCount << std::endl;
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

	int addVariables(int count) {
		if(comments) out << "c add " << count << " variables" << std::endl;
		int vars = this->varCount;
		this->varCount += count;
		return vars;
	}

	int addVariablesExactlyOneNaive(int count, int optionCount) {
		if(comments)
			out << "c " << count << " vars added with " << optionCount << " options"
				<< " with exactly one constraint using the naive encoding\n";
		int vars = this->varCount;
		this->varCount += count * optionCount;
		if(comments) out << "c vars: [" << vars << "," << varCount-1 << "]\n";

		if(comments) out << "c at least one option\n";
		for(int c = 0; c < count; c++)
			printClause(iotaCountSpan(vars + c * optionCount, optionCount));

		if(comments) out << "c at most one option\n";
		for(int c = 0; c < count; c++)
			printNaiveAtMostOne(iotaCountSpan(vars + c * optionCount, optionCount));

		if(comments) out << "c" << std::endl;
		return vars;
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

		if(comments) out << "c " << std::endl;
		return vars;
	}
	
	int addVariablesExactlyOneCommander(int count, int optionCount, int groupSize) {
		assert(optionCount % groupSize == 0);
		int groupCount = optionCount / groupSize;

		if(comments)
			out << "c " << count << " vars added with " << optionCount << " options"
				<< " with exactly one contraint"
				<< " using the commander encoding\n";

		if(comments)
			out << "c " << groupCount << " groups with " << groupSize << " elements"
				<< " per group\n";

		int optionVars = varCount;
		varCount += count * optionCount;
		if(comments) out << "c optionVars: [" << optionVars << "," << varCount-1 << "]\n";

		int commanderVars = varCount;
		varCount += count * groupCount;
		if(comments) out << "c commanderVars: [" << commanderVars << "," << varCount-1 << "]\n";

		if(comments) out << "c at least one option per variable:\n";
		for(int c = 0; c < count; c++)
			printClause(iotaCountSpan(optionVars + c * optionCount,
			                                optionCount));

		if(comments) out << "c at most one commander:\n";
		for(int c = 0; c < count; c++)
			printNaiveAtMostOne(iotaCountSpan(commanderVars + c * groupCount,
			                                        groupCount));

		if(comments) out << "c at least one in group:\n";
		for(int c = 0; c < count; c++)
			for(int g = 0; g < groupCount; g++)
				printClause(-(commanderVars + c * groupCount + g),
					iotaCountSpan(optionVars + c * optionCount + g * groupSize,
				                        groupSize));
		if(comments) out << "c at most one in group:\n";
		for(int c = 0; c < count; c++)
			for(int g = 0; g < groupCount; g++)
				printNaiveAtMostOne(-(commanderVars + c * groupCount + g),
					iotaCountSpan(optionVars + c * optionCount + g * groupSize,
				                        groupSize));

		if(comments) out << "c " << std::endl;
		return optionVars;
	}

	void printCommanderExactlyOne(std::vector<int> &vars, int groupSize) {
		assert(vars.size() % groupSize == 0);

		int groupCount = vars.size() / groupSize;

		int commanderVars = this->varCount;
		this->varCount += groupCount;

		// at least one commander
		printClause(iotaCountSpan(commanderVars, groupCount));

		// at most one commander
		printNaiveAtMostOne(iotaCountSpan(commanderVars, groupCount));

		auto varsSpan = Span(vars);

		// at least one in group
		for(int g = 0; g < groupCount; g++)
			printClause(-(commanderVars + g), subSpan(varsSpan, g * groupSize, groupSize));

		// at most one in group
		for(int g = 0; g < groupCount; g++)
			printNaiveAtMostOne(-(commanderVars + g), subSpan(varsSpan, g * groupSize, groupSize));
	}
};

#endif
