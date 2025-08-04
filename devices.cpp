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

int main(void)
{
    try
    {
        std::vector<cl::Platform> platforms;
        cl::Platform::get(&platforms);

        for (auto& p : platforms)
        {
            auto name = p.getInfo<CL_PLATFORM_NAME>();
            std::cout << "platform name " << name << std::endl;

            std::vector<cl::Device> devices;
            p.getDevices(CL_DEVICE_TYPE_ALL, &devices);
            for (auto& device : devices)
            {
                auto id = device.getInfo<CL_DEVICE_VENDOR_ID>();
                std::cout << "   device id " << id << std::endl;
            }
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
