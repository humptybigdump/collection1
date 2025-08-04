// Copyright 2009-2021 Intel Corporation
// SPDX-License-Identifier: Apache-2.0

#pragma once

#include <math/vec.h>

namespace embree {
    Light_SampleRes DirectionalLight_sample(const Light* super,
                                                const Sample& dg,
                                                const Vec2f& s);

    Light_EvalRes DirectionalLight_eval(const Light* super,
                                        const Sample&,
                                        const Vec3fa& dir);

    extern "C" void* DirectionalLight_create();

    extern "C" void DirectionalLight_set(void* super,
                                         const Vec3fa& direction,
                                         const Vec3fa& radiance,
                                         float cosAngle);
}
