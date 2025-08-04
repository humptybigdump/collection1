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

class A3Task3CPU {
public:
    A3Task3CPU(AppResources &app, int workGroupSize);
    void cleanup();

    void prepare(std::vector<float> &input, const uint32_t nBins);
    void compute();
    std::vector<int> result() const;

    float mstime, insideTime;
    std::string shaderName = workingDir + "build/shaders/histogram_naive.comp.spv";
    void useNaive(){
        shaderName= workingDir + "build/shaders/histogram_naive.comp.spv";
    }
    void useLocalOpti(){
        shaderName= workingDir + "build/shaders/histogram.comp.spv";
    }
private:
    struct PushConstant
    {
        int size;
    } push;

    AppResources &app;
    uint32_t workGroupSize, nBins;

    std::vector<float> mpInput;

    Buffer matrixBuffer, histoBuffer;

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


class A3Task3 {
public:
    A3Task3(float* input, uint32_t size, uint32_t numBins);

    bool evaluateSolution(A3Task3CPU& solution);
    std::vector<int> reference;

private:
    void computeReference();
    std::vector<float> input; 
    uint32_t numBins;
};
  
void print_histogram(const std::vector<int> &h);