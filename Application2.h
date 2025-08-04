#pragma once
#include "helper.hpp"


class Application2 : public Application {
public:
    Application2(int argc, char** argv) : Application(argc, argv, "Assignment 1") {
    }

private:
    Vec3fa renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSampler& sampler) override;

    void drawGUI() override {
        ImGui::Checkbox("Bounding Box", &boundingBox);
    }

    void initScene() override;

    void emptyScene();

    void gnomeScene();

    void horseScene();

    void heterogenousScene();

    float colorLight[3] = {1.0f, 1.0f, 1.0f};
    bool boundingBox = true;
};
