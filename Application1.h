#pragma once
#include "helper.hpp"


class Application1 : public Application {
public:
    Application1(int argc, char** argv) : Application(argc, argv, "Assignment 1") {
    }

private:
    Vec3fa renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSampler& sampler) override;

    void drawGUI() override {
    }

    void initScene() override;

    void standardScene();

    void veachScene();

    float colorLight[3] = {1.0f, 1.0f, 1.0f};
};
