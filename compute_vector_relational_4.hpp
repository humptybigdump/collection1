#pragma once

#include "setup.hpp"
#include <cstring>
#include <limits>

namespace glm{
namespace detail
{
	template <typename T, bool isFloat = std::numeric_limits<T>::is_iec559>
	struct compute_equal
	{
		GLM_FUNC_QUALIFIER static bool call(T a, T b)
		{
			return a == b;
		}
	};

	template <typename T>
	struct compute_equal<T, true>
	{
		GLM_FUNC_QUALIFIER static bool call(T a, T b)
		{
			return std::memcmp(&a, &b, sizeof(T)) == 0;
		}
	};
}//namespace detail
}//namespace glm
// CG_REVISION 506b554aed3a96df3375628be89a0c326e26087b
