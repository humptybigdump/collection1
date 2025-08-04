#include "A3Task1.h"

template<typename T, typename V>
T ceilDiv(T x, V y) {
    return x / y + (x % y != 0);
}

A3Task1CPU::A3Task1CPU(AppResources &app, uint32_t workGroupSize_x, uint32_t workGroupSize_y) :
    app(app), workGroupSize_x(workGroupSize_x), workGroupSize_y(workGroupSize_y) {

}

void A3Task1CPU::prepare(const std::vector<float> &input, const std::vector<float> ker, uint32_t width, uint32_t height)
{
    kernel=ker;
    float kernelWeight = 0;
    for (int i = 0; i < kernel.size(); i++)
            kernelWeight += kernel[i];

    if (kernelWeight > 0)
        kernelWeight = 1.0f / kernelWeight; // Use this for normalization
    else
        kernelWeight = 1.0f;

    w=p=width;
    h=height;
    // If width is not a multiple of the transaction size (32 floats)
    // -> resize
    if(w%32 != 0)
        p = w + 32 - (w%32);

    imgInput.resize(p*h,0.f);
    for (int j = 0 ; j < h; j++)
        memcpy(imgInput.data()+p*j, input.data()+w*j, w*sizeof(float));
    
    cleanup();

    Cmn::addStorage(bindings, 0);
    Cmn::addStorage(bindings, 1);
    Cmn::createDescriptorSetLayout(app.device, bindings, descriptorSetLayout);
    // Define push constant values (no 'create' needed!)
    vk::PushConstantRange pcr(
        vk::ShaderStageFlagBits::eCompute,            // Shader stage push constant will go to
        0,                                            // Offset into given data to pass to push constant
        sizeof(PushConstant)                          // Size of data being passed
    );
    // Pipeline Layout
    vk::PipelineLayoutCreateInfo pipInfo(vk::PipelineLayoutCreateFlags(), 1U, &descriptorSetLayout, 1U, &pcr);
    pipelineLayout = app.device.createPipelineLayout(pipInfo);

    Cmn::createShader(app.device, shaderModule, workingDir + "build/shaders/conv3x3.comp.spv");
        // Specialization constant for workgroup size
    std::array<vk::SpecializationMapEntry, 2> specEntries = std::array<vk::SpecializationMapEntry, 2>{ 
        {{0U, 0U, sizeof(workGroupSize_x)},
        {1U, sizeof(int), sizeof(workGroupSize_y)}},
    }; 
    std::array<uint32_t, 2> specValues = {workGroupSize_x, workGroupSize_y}; //for workgroup sizes


    vk::SpecializationInfo specInfo = vk::SpecializationInfo(CAST(specEntries), specEntries.data(),
                                    CAST(specValues) * sizeof(int), specValues.data());
    Cmn::createPipeline(app.device, pipeline, pipelineLayout, specInfo, shaderModule);

    createBuffer(app.pDevice, app.device, imgInput.size() * sizeof(imgInput[0]),
        vk::BufferUsageFlagBits::eTransferDst | vk::BufferUsageFlagBits::eTransferSrc | vk::BufferUsageFlagBits::eStorageBuffer,
        vk::MemoryPropertyFlagBits::eDeviceLocal, "inBuf", inBuf.buf, inBuf.mem);

    createBuffer(app.pDevice, app.device, imgInput.size() * sizeof(imgInput[0]),
        vk::BufferUsageFlagBits::eTransferSrc | vk::BufferUsageFlagBits::eStorageBuffer,
        vk::MemoryPropertyFlagBits::eDeviceLocal, "outBuf", outBuf.buf, outBuf.mem);

    fillDeviceWithStagingBuffer(app.pDevice, app.device, app.transferCommandPool, app.transferQueue, inBuf, imgInput);
    
    Cmn::createDescriptorPool(app.device, bindings, descriptorPool);
    Cmn::allocateDescriptorSet(app.device, descriptorSet, descriptorPool, descriptorSetLayout);
    Cmn::bindBuffers(app.device, inBuf.buf, descriptorSet, 0);
    Cmn::bindBuffers(app.device, outBuf.buf, descriptorSet, 1);
    push.width=w;
    push.height=h;
    push.pitch=p;
    push.kernelWeight=kernelWeight;
    for( int i = 0; i<ker.size(); i++)
        push.kernel[i]=kernel[i];
}

void A3Task1CPU::compute()
{
    uint32_t dx = (w + workGroupSize_x - 1) / workGroupSize_x;
    uint32_t dy = (h + workGroupSize_y - 1) / workGroupSize_y;
    vk::CommandBufferAllocateInfo allocInfo(
        app.computeCommandPool,                    // Commandpool 
        vk::CommandBufferLevel::ePrimary,          // ePrimary - Buffer you submit directly to queue. Cant be called by other buffers.
        1U);
    vk::CommandBuffer cb = app.device.allocateCommandBuffers( allocInfo )[0];

    // Information about how to begin each command buffer
    vk::CommandBufferBeginInfo beginInfo(vk::CommandBufferUsageFlagBits::eOneTimeSubmit);

    cb.begin(beginInfo);
    cb.resetQueryPool(app.queryPool, 0, 2);
    cb.writeTimestamp(vk::PipelineStageFlagBits::eAllCommands, app.queryPool, 0);
    cb.bindPipeline(vk::PipelineBindPoint::eCompute, pipeline);
    cb.bindDescriptorSets(vk::PipelineBindPoint::eCompute, pipelineLayout,
                        0U, 1U, &descriptorSet, 0U, nullptr);
    cb.pushConstants(pipelineLayout, vk::ShaderStageFlagBits::eCompute,
                     0, sizeof(PushConstant), &push);
    cb.dispatch(dx, dy, 1);
    cb.writeTimestamp(vk::PipelineStageFlagBits::eAllCommands, app.queryPool, 1);
    cb.end();

    // Submit the command buffer to the queue and set up a fence.
    
    vk::SubmitInfo submitInfo = vk::SubmitInfo(0, nullptr, nullptr, 1, &cb); // Submit a single command buffer

    HostTimer timer;

    app.computeQueue.submit({submitInfo});
    app.device.waitIdle();

    mstime = timer.elapsed() * 1000;

    app.device.freeCommandBuffers(app.computeCommandPool, 1U, &cb);

    uint64_t timestamps[2];
    vk::Result result = app.device.getQueryPoolResults(app.queryPool, 0, 2, sizeof(timestamps), &timestamps, sizeof(timestamps[0]), vk::QueryResultFlagBits::e64);
    assert(result == vk::Result::eSuccess);
    uint64_t timediff = timestamps[1] - timestamps[0];
    vk::PhysicalDeviceProperties properties = app.pDevice.getProperties();
    uint64_t nanoseconds = properties.limits.timestampPeriod * timediff;
    insideTime = nanoseconds / 1000000.f;
}

std::vector<float> A3Task1CPU::result() const
{   
    //std::cout<<w<<", "<<h<<std::endl;
    std::vector<float> resultPitched(p*h, 0.f);
    fillHostWithStagingBuffer(app.pDevice, app.device, app.transferCommandPool, app.transferQueue, outBuf, resultPitched);

    std::vector<float> result(w*h, 0.f);
    // re-align to remove the pitch
    for(int i = 0; i<h; i++)
        memcpy(result.data()+w*i,resultPitched.data()+p*i,w*sizeof(float));
    return result;
}

void A3Task1CPU::cleanup()
{
    app.device.destroyDescriptorPool(descriptorPool);

    app.device.destroyPipeline(pipeline);
    app.device.destroyShaderModule(shaderModule);

    app.device.destroyPipelineLayout(pipelineLayout);
    app.device.destroyDescriptorSetLayout(descriptorSetLayout);
    bindings.clear();

    auto Bclean = [&](Buffer &b){
        app.device.destroyBuffer(b.buf);
        app.device.freeMemory(b.mem);
    };

    Bclean(inBuf);
    Bclean(outBuf);
}