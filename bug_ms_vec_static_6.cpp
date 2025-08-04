#include <glm/glm.hpp>

#if GLM_HAS_ALIGNED_TYPE
struct vec2;

struct _swizzle
{
	char _buffer[1];
};

struct vec2
{
	GLM_CONSTEXPR_CTOR vec2() :
		x(0), y(0)
	{}

	union
	{
		struct { float x, y; };
		struct { _swizzle xx; };
	};
};
#endif

// Visual C++ has a bug generating the error: fatal error C1001: An internal error has occurred in the compiler.
// vec2 Bar;

int main()
{
	return 0;
}
// CG_REVISION cf19ad39f6041ea8c1e7b55d2580a46744918fcd
