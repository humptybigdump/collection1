#define GLM_FORCE_SIZE_T_LENGTH
#include <glm/glm.hpp>
#include <glm/ext.hpp>

template <typename genType>
genType add(genType const& a, genType const& b)
{
	genType result(0);
	for(glm::length_t i = 0; i < a.length(); ++i)
		result[i] = a[i] + b[i];
	return result;
}

int main()
{
	int Error = 0;

	glm::ivec4 v(1);
	Error += add(v, v) == glm::ivec4(2) ? 0 : 1;

	return Error;
}
// CG_REVISION 506b554aed3a96df3375628be89a0c326e26087b
