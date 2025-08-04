/// @ref core
/// @file glm/detail/_fixes.hpp

#include <cmath>

//! Workaround for compatibility with other libraries
#ifdef max
#undef max
#endif

//! Workaround for compatibility with other libraries
#ifdef min
#undef min
#endif

//! Workaround for Android
#ifdef isnan
#undef isnan
#endif

//! Workaround for Android
#ifdef isinf
#undef isinf
#endif

//! Workaround for Chrone Native Client
#ifdef log2
#undef log2
#endif

// CG_REVISION 0a5db8c32feeaa963bf293b1caa14d49e9140499
