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

class A3Task2CPU {
public:
    A3Task2CPU(AppResources &app, uint32_t workGrpSize_H[2], uint32_t workGrpSize_V[2]);
    void cleanup();

    void prepare(const std::vector<float> &input, const std::vector<float> horizKer, const std::vector<float> vertKer, uint32_t width, uint32_t height, uint32_t H_ELEMENTS, uint32_t V_ELEMENTS);
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
        float kernel[32];
    };
    PushConstant pushHoriz;
    PushConstant pushVert;
    AppResources &app;
    uint32_t workGroupSize_H[2], workGroupSize_V[2];
    int w, h, p, H_elements, V_elements;
    std::vector<float> imgInput;
    std::vector<float> kernelHoriz, kernelVert;

    Buffer inOutBuf, interBuf;

    // Descriptor & Pipeline Layout
    std::vector<vk::DescriptorSetLayoutBinding> bindings;
    vk::DescriptorSetLayout descriptorSetLayout;
    vk::PipelineLayout pipelineLayoutHoriz;
    vk::PipelineLayout pipelineLayoutVert;


    // Local PPS Pipeline
    vk::ShaderModule shaderModuleHoriz;
    vk::ShaderModule shaderModuleVert;
    vk::Pipeline pipelineHoriz;
    vk::Pipeline pipelineVert;

    // Descriptor Pool
    vk::DescriptorPool descriptorPool;

    // Per-dispatch data
    vk::DescriptorSet descriptorSet;
};

class A3Task2 {
public:
    A3Task2(float* input, 
    std::vector<float> kernelH, std::vector<float> kernelV, 
    uint32_t w, uint32_t h, uint32_t h_elements, uint32_t v_elements);

    bool evaluateSolution(A3Task2CPU& solution);

private:
    void computeReference();
    std::vector<float> input;
    uint32_t w, h, nH, nV; //nH: number of elements treated per thread
    std::vector<float> reference;
    std::vector<float> kernelH, kernelV;
};
  