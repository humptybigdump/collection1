/*
 * Copyright (c) 2020 Thomas Perschke <thomas.perschke@iosb.fraunhofer.de>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */
#define CL_HPP_ENABLE_EXCEPTIONS
#define CL_HPP_TARGET_OPENCL_VERSION 200
#include <CL/cl2.hpp>
#include <iostream>
#include <vector>

namespace
{

template <class T, class A>
std::size_t bytes_in_vector(std::vector<T, A> const& v)
{
    return v.size() * sizeof(T);
}

}

int main(void)
{
    try
    {

        auto context = cl::Context(CL_DEVICE_TYPE_GPU, nullptr, nullptr, nullptr, nullptr);

        auto devices = context.getInfo<CL_CONTEXT_DEVICES>();

        if (devices.empty())
        {
            std::cout << "Context contains no device" << std::endl;
        }

        auto queue = cl::CommandQueue(context, devices[0]);

        const int Aini = 9;

        std::vector<int> A(1000, Aini);
        std::vector<int> B(1000, 0);

        auto buffer_in = cl::Buffer(context, CL_MEM_READ_ONLY, bytes_in_vector(A), nullptr, nullptr);

        auto buffer_out = cl::Buffer(context, CL_MEM_WRITE_ONLY, bytes_in_vector(B), nullptr, nullptr);

        queue.enqueueWriteBuffer(buffer_in, CL_TRUE, 0, bytes_in_vector(A), (void*)A.data());
        queue.enqueueCopyBuffer(buffer_in, buffer_out, 0, 0, bytes_in_vector(A));
        queue.enqueueReadBuffer(buffer_out, CL_TRUE, 0, bytes_in_vector(B), (void*)B.data());

        int wrong_values { 0 };

        for (const auto& val : B)
        {
            if (val != Aini)
            {
                ++wrong_values;
            }
        }

        if (wrong_values == 0)
        {
            std::cout << "Test O.K." << std::endl;
        }
        else
        {
            std::cout << "Test FAILURE" << std::endl;
        }
    }
    catch (cl::Error& err)
    {
        std::cout << err.what() << "  " << err.err() << std::endl;
        return 1;
    }
    catch (std::exception& err)
    {
        std::cout << err.what() << std::endl;
        return 1;
    }
    return 0;
}
