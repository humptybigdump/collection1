#include <iostream>
#include <cstdlib>
#define VULKAN_HPP_DISPATCH_LOADER_DYNAMIC 1

#include <vulkan/vulkan.hpp>
#include <fstream>
#include <vector>
#include <algorithm>
#include "initialization.h"
#include "utils.h"
#include "task_common.h"
#include "A1task1.h"

#include <cstdlib> // for rand
#include <ctime> // for time

// DO NOT CHANGE THIS FILE

void defaultVectors(std::vector<int> &in1, std::vector<int> &in2, size_t size)
{
    //Prepare data
    in1 = std::vector<int>(size, 0u);
    // Seed the random number generator
    std::srand(std::time(nullptr)); 

    for (size_t i = 0; i < in1.size(); i++)
        in1[i] = static_cast<int>(i);

    in2 = std::vector<int>(in1);
    std::reverse(in2.begin(), in2.end());
}

//Requires to have called prepare() because we need the buffers to be correctly created
void A1_Task1::defaultValues()
{
    std::vector<int> inputVec, inputVec2;
    defaultVectors(inputVec, inputVec2, this->workloadSize);
    //Fill buffers
    //std::cout << "Filling buffers..." << std::endl;
    fillDeviceWithStagingBuffer(app.pDevice, app.device, app.transferCommandPool, app.transferQueue, inBuffer1, inputVec);
    fillDeviceWithStagingBuffer(app.pDevice, app.device, app.transferCommandPool, app.transferQueue, inBuffer2, inputVec2);
}

bool A1_Task1::checkDefaultValues()
{
    //Gather the output data after having called compute()
    std::vector<unsigned int> result(this->workloadSize, 1u);

    fillHostWithStagingBuffer(app.pDevice, app.device, app.transferCommandPool, app.transferQueue, outBuffer, result);

    std::vector<int> inputVec, inputVec2;
    defaultVectors(inputVec, inputVec2, this->workloadSize);
    std::vector<int> outputVec(this->workloadSize, 0u);
    std::transform(inputVec.begin(), inputVec.end(), inputVec2.begin(), outputVec.begin(), std::plus<int>());

    if (std::equal(result.begin(), result.end(), outputVec.begin()))
        return true;
    else
    {
        std::cout << "error" << std::endl;
        return false;
    }
}
