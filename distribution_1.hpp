#pragma once
#include <sys/platform.h>
#include <sys/sysinfo.h>
#include <sys/alloc.h>

#include <sys/ref.h>
#include <sys/vector.h>
#include <math/vec2.h>
#include <math/vec3.h>
#include <math/vec4.h>
#include <math/bbox.h>
#include <math/lbbox.h>
#include <math/affinespace.h>
#include <sys/filename.h>
#include <sys/estring.h>
#include <lexers/tokenstream.h>
#include <lexers/streamfilters.h>
#include <lexers/parsestream.h>
#include <atomic>

#include <sstream>
#include <vector>
#include <memory>
#include <map>
#include <set>
#include <deque>

#include "helper.hpp"

#include <sys/sysinfo.h>

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

#include "camera.hpp"
#include "ray.hpp"
#include "random_sampler.hpp"
#include "random_sampler_wrapper.hpp"


// https://github.com/mmp/pbrt-v3/blob/master/src/core/pbrt.h#L403

template <typename Predicate>
int FindInterval(int size, const Predicate& pred) {
	int first = 0, len = size;
	while (len > 0) {
		int half = len >> 1, middle = first + half;
		// Bisect range based on value of _pred_ at _middle_
		if (pred(middle)) {
			first = middle + 1;
			len -= half + 1;
		}
		else
			len = half;
	}
	return clamp(first - 1, 0, size - 2);
}
struct Distribution1D {
	Distribution1D(){}

	// Distribution1D Public Methods
	Distribution1D(const float* f, int n) : func(f, f + n), cdf(n + 1) {
		// Compute integral of step function at $x_i$
		cdf[0] = 0;
		for (int i = 1; i < n + 1; ++i) cdf[i] = cdf[i - 1] + func[i - 1] / n;

		// Transform step function integral into CDF
		funcInt = cdf[n];
		if (funcInt == 0) {
			for (int i = 1; i < n + 1; ++i) cdf[i] = float(i) / float(n);
		}
		else {
			for (int i = 1; i < n + 1; ++i) cdf[i] /= funcInt;
		}
	}
	int Count() const { return (int)func.size(); }
	float SampleContinuous(float u, float* pdf, int* off = nullptr) const {
		// Find surrounding CDF segments and _offset_
		int offset = FindInterval((int)cdf.size(),
			[&](int index) { return cdf[index] <= u; });
		if (off) *off = offset;
		// Compute offset along CDF segment
		float du = u - cdf[offset];
		if ((cdf[offset + 1] - cdf[offset]) > 0) {
			du /= (cdf[offset + 1] - cdf[offset]);
		}
		assert(!std::isnan(du));

		// Compute PDF for sampled offset
		if (pdf) *pdf = (funcInt > 0) ? func[offset] / funcInt : 0;

		// Return $x\in{}[0,1)$ corresponding to sample
		return (offset + du) / Count();
	}
	int SampleDiscrete(float u, float* pdf = nullptr,
		float* uRemapped = nullptr) const {
		// Find surrounding CDF segments and _offset_
		int offset = FindInterval((int)cdf.size(),
			[&](int index) { return cdf[index] <= u; });
		if (pdf) *pdf = (funcInt > 0) ? func[offset] / (funcInt * Count()) : 0;
		if (uRemapped)
			*uRemapped = (u - cdf[offset]) / (cdf[offset + 1] - cdf[offset]);
		if (uRemapped) assert(*uRemapped >= 0.f && *uRemapped <= 1.f);
		return offset;
	}
	float DiscretePDF(int index) const {
		assert(index >= 0 && index < Count());
		return func[index] / (funcInt * Count());
	}

	// Distribution1D Public Data
	std::vector<float> func, cdf;
	float funcInt;
};