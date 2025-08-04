// Copyright 2009-2021 Intel Corporation
// SPDX-License-Identifier: Apache-2.0

#pragma once

#include <math/vec.h>
#include "light.h"

namespace embree {
    Light_SampleRes AmbientLight_sample(const Light* super,
                                        const Sample& dg,
                                        const Vec2f& s);
    Light_EvalRes AmbientLight_eval(const Light* super,
                                    const Sample& dg,
                                    const Vec3fa& dir);

    extern "C" void* AmbientLight_create();

    extern "C" void AmbientLight_set(void* super,
                                     const Vec3fa& radiance);

    extern "C" void Light_destroy(Light* light);
}
