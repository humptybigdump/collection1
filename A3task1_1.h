#pragma once

#include "helper.h"

#include <iostream>
#include <cstdlib>
#define VULKAN_HPP_DISPATCH_LOADER_DYNAMIC 1

#include <vulkan/vulkan.hpp>
#include <fstream>
#include <vector>
#include "initialization.h"
#include "utils.h"
#include "task_common.h"
#include "host_timer.h"

class A3Task1CPU {
public:
    A3Task1CPU(AppResources &app, uint32_t workGroupSize_x, uint32_t workGroupSize_y);
    void cleanup();

    void prepare(const std::vector<float> &input, const std::vector<float> ker, uint32_t w, uint32_t h);
    void compute();
    std::vector<float> result() const;

    float mstime, insideTime;

private:
    struct PushConstant
    {
        uint32_t width;
        uint32_t height;
        uint32_t pitch;
        float kernelWeight;
        float kernel[9];
    } push;

    AppResources &app;
    uint32_t workGroupSize_x, workGroupSize_y;
    int w, h, p;
    std::vector<float> imgInput;
    std::vector<float> kernel;

    Buffer inBuf, outBuf;

    // Descriptor & Pipeline Layout
    std::vector<vk::DescriptorSetLayoutBinding> bindings;
    vk::DescriptorSetLayout descriptorSetLayout;
    vk::PipelineLayout pipelineLayout;

    // Local PPS Pipeline
    vk::ShaderModule shaderModule;
    vk::Pipeline pipeline;

    // Descriptor Pool
    vk::DescriptorPool descriptorPool;

    // Per-dispatch data
    vk::DescriptorSet descriptorSet;
};

class A3Task1 {
public:
    A3Task1(float* input, float k[3][3], uint32_t w, uint32_t h);
    A3Task1(std::vector<float> input, float k[3][3], uint32_t w, uint32_t h);

    bool evaluateSolution(A3Task1CPU& solution);

private:
    void computeReference();
    std::vector<float> input;
    uint32_t w, h;
    std::vector<float> reference;
    float kernel[3][3];
};