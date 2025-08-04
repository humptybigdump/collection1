#include <glm/glm.hpp>

int test_float_size()
{
	return
		sizeof(glm::float_t) != sizeof(glm::lowp_float) &&
		sizeof(glm::float_t) != sizeof(glm::mediump_float) && 
		sizeof(glm::float_t) != sizeof(glm::highp_float);
}

int test_float_precision()
{
	return (
		sizeof(glm::lowp_float) <= sizeof(glm::mediump_float) && 
		sizeof(glm::mediump_float) <= sizeof(glm::highp_float)) ? 0 : 1;
}

int test_vec2()
{
	return 0;
}

int main()
{
	int Error = 0;

	Error += test_float_size();
	Error += test_float_precision();

	return Error;
}
// CG_REVISION 0a5db8c32feeaa963bf293b1caa14d49e9140499
