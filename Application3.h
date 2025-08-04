#pragma once
#include "helper.hpp"
#include "application_integrator.h"


class Application3 : public ApplicationIntegrator {
public:
    Application3(int argc, char** argv) : ApplicationIntegrator(argc, argv, "Assignment 3") {
    }

private:
    Vec3fa renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSamplerWrapper& sampler) override;


    void drawGUI() override {
		ApplicationIntegrator::drawGUI(); // NEW!
    }

    void initScene() override;

    void standardScene();

    void causticScene();

    float colorLight[3] = {1.0f, 1.0f, 1.0f};
};
