#include <iostream>
#include <cstdlib>
#define VULKAN_HPP_DISPATCH_LOADER_DYNAMIC 1

#include <vulkan/vulkan.hpp>
#include <fstream>
#include <vector>
#include "initialization.h"
#include "utils.h"
#include "task_common.h"
#include "A1task2.h"


#include <cstdlib> // for rand
#include <ctime> // for time

// DON'T CHANGE IT!

/* requires to have called prepare() because we need the buffers to be correctly created*/
std::vector<int> A1_Task2::incArray()
{

	std::srand(std::time(nullptr));

    // === prepare data ===
    std::vector<int> inputVec(workloadSize, 0u);
    for (size_t i = 0; i < inputVec.size(); i++)
    {
        inputVec[i] = static_cast<int>(i);
    }
    return inputVec;
}

bool A1_Task2::checkDefaultValues()
{
    // ### gather the output data after having called compute() ###
    std::vector<int> result(workloadSize, 1u);

    fillHostWithStagingBuffer(app.pDevice, app.device, app.transferCommandPool, app.transferQueue, outBuffer, result);
    std::vector<int> input = incArray();

    std::vector<int> rotate = rotateCPU(input, workloadSize_w, workloadSize_h);
    int errors = 0;
    for(int i = 0 ; i < rotate.size(); i++)
        if(rotate[i] != result[i])
            errors++;
    if(errors>0)
        std::cout<<std::endl<<"=== There were " << errors << " error(s). ===" << std::endl;

    return errors == 0;
}