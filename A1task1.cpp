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


void A1_Task1::prepare(unsigned int size)
{
    this->workloadSize = size;
    
    // ### Fill the descriptorLayoutBindings  ###

    //DescriptorSetLayout holds the shape and usage of buffers but not the buffers themselves

    // ### Push Constant ###

    // ### Create Pipeline Layout ###
    //task.pipelineLayout = ...

    // ### create buffers ###
    //this->inBuffer1 = ...
    //this->inBuffer2
    //this->outBuffer

    // ### Fills inBuffer1 and inBuffer2 ###

    // This creates default values 
    this->defaultValues();

    // ### Create  structures ###
    // ### DescriptorSet is created but not filled yet ###
    // ### Bind buffers to descriptor set ### (calls update several times)


    // ### Preparation work done! ###
}

void A1_Task1::compute(uint32_t dx, uint32_t dy, uint32_t dz, std::string file)
{
    uint32_t groupCount; // todo: fill
    PushStruct push; // todo: fill
    // ### Create ShaderModule ###
    vk::PipelineShaderStageCreateInfo  stageInfo; // todo: fill 

    // ### Specialization constants
    // constantID, offset, sizeof(type)

    // ### Create Pipeline ###
    vk::ComputePipelineCreateInfo  computeInfo; // todo: fill

    // ### finally do the compute ###
    // call dispatchWork
}

void A1_Task1::dispatchWork(uint32_t dx, uint32_t dy, uint32_t dz, PushStruct &pushConstant)
{
    /* ### Create Command Buffer ### */

    /* ### Call Begin and register commands ### */

    /* ### End of Command Buffer, enqueue it and use a Fence ### */

    /* ### Collect data from the query Pool ### */

    /* Uncomment this once you've finished this function:
    ###
    uint64_t timestamps[2];
    vk::Result result = app.device.getQueryPoolResults(app.queryPool, 0, 2, sizeof(timestamps), &timestamps, sizeof(timestamps[0]), vk::QueryResultFlagBits::e64);
    assert(result == vk::Result::eSuccess);
    uint64_t timediff = timestamps[1] - timestamps[0];
    vk::PhysicalDeviceProperties properties = app.pDevice.getProperties();
    uint64_t nanoseconds = properties.limits.timestampPeriod * timediff;

    mstime = nanoseconds / 1000000.f;
    ###
    */
}