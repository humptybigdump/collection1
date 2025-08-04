#ifndef _CNF_GEN_HPP
#define _CNF_GEN_HPP

#include <iostream>
#include <sstream>
#include <cassert>
#include <vector>

#include <version>
#ifdef __cpp_lib_ranges
#define CNF_HAS_RANGES
#include <ranges>
#define CNF_BEGIN std::ranges::begin
#define CNF_END   std::ranges::end
#else
#define CNF_BEGIN std::begin
#define CNF_END   std::end
#endif


namespace rngutil {
	template<typename T, typename U>
	constexpr auto iota_count(T&& t, U&& u) {
		#ifdef CNF_HAS_RANGES
		return std::views::iota(t, t + u);
		#else
		std::vector<int> values;
		for(int i = 0; i < u; i++) values.push_back(t + i);
		return values;
		#endif
	}

	template<typename F, typename V>
	auto _impl_call_with_range(F func, V& vec) {
		func(vec);
	}

	template<typename F, typename V, typename T, typename... Ts>
	auto _impl_call_with_range(F func, V& vec, T head, Ts... tail) {
		vec.push_back(head);
		_impl_call_with_range(func, vec, tail...);
	}

	#ifdef CNF_HAS_RANGES
	template<typename F, typename V, std::ranges::range R, typename... Ts>
	auto _impl_call_with_range(F func, V& vec, R head, Ts... tail) {
		vec.insert(vec.end(), std::ranges::begin(head), std::ranges::end(head));
		_impl_call_with_range(func, vec, tail...);
	}
	#else
	template<typename F, typename V, typename T, typename... Ts>
	auto _impl_call_with_range(F func, V& vec, std::vector<T> head, Ts... tail) {
		vec.insert(vec.end(), std::begin(head), std::end(head));
		_impl_call_with_range(func, vec, tail...);
	}
	#endif

	template<typename F, typename T, typename... Ts>
	auto call_with_range(F func, T head, Ts... tail) {
		std::vector vec { head };
		_impl_call_with_range(func, vec, tail...);
	}

	#ifdef CNF_HAS_RANGES
	template<typename F, std::ranges::range T, typename... Ts>
	auto call_with_range(F func, T head, Ts... tail) {
		std::vector vec { *std::ranges::begin(head) };
		for(auto it = std::ranges::begin(head); it != std::ranges::end(head); it++)
			if(it != std::ranges::begin(head)) vec.push_back(*it);
		_impl_call_with_range(func, vec, tail...);
	}
	#else
	template<typename F, typename T, typename... Ts>
	auto call_with_range(F func, std::vector<T> head, Ts... tail) {
		std::vector vec = head;
		_impl_call_with_range(func, vec, tail...);
	}
	#endif
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
		rngutil::call_with_range([this](const auto& vars) { 
			for(Var v : vars) out << v << " ";
			out << "0\n";
		}, vars...);
		clauseCount++;
	}

	template<typename... T>
	void printNaiveAtMostOne(T... vars) {
		rngutil::call_with_range([this](const auto& vars) {
			/*
			// Broken in GCC 10 (https://stackoverflow.com/a/61869643/13565664)
			auto tail = vars | std::views::drop(1);
			if(vars.size() == 0) return;
			for(Var i : tail) printClause(-vars.front(), -i);
			printNaiveAtMostOne(std::ranges::ref_viewi(tail));
			*/

			auto beginIt = CNF_BEGIN(vars);
			auto endIt   = CNF_END(vars);
			while(beginIt != endIt) {
				for(auto it = beginIt+1; it != endIt; it++)
					printClause(-*beginIt, -*it);
				beginIt++;
			}
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
			printClause(rngutil::iota_count(vars + c * optionCount, optionCount));

		if(comments) out << "c at most one option\n";
		for(int c = 0; c < count; c++)
			printNaiveAtMostOne(rngutil::iota_count(vars + c * optionCount, optionCount));

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
			printClause(rngutil::iota_count(optionVars + c * optionCount,
			                                optionCount));

		if(comments) out << "c at most one commander:\n";
		for(int c = 0; c < count; c++)
			printNaiveAtMostOne(rngutil::iota_count(commanderVars + c * groupCount,
			                                        groupCount));

		if(comments) out << "c at least one in group:\n";
		for(int c = 0; c < count; c++)
			for(int g = 0; g < groupCount; g++)
				printClause(-(commanderVars + c * groupCount + g),
					rngutil::iota_count(optionVars + c * optionCount + g * groupSize,
				                        groupSize));
		if(comments) out << "c at most one in group:\n";
		for(int c = 0; c < count; c++)
			for(int g = 0; g < groupCount; g++)
				printNaiveAtMostOne(-(commanderVars + c * groupCount + g),
					rngutil::iota_count(optionVars + c * optionCount + g * groupSize,
				                        groupSize));

		if(comments) out << "c " << std::endl;
		return optionVars;
	}
};

#endif
