#pragma once
#include "helper.hpp"


class Application1 : public Application {
public:
    Application1(int argc, char** argv) : Application(argc, argv, "Assignment 1") {
    }

private:
    Vec3fa renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSamplerWrapper& sampler) override;

	void drawGUI() override {
		ImGui::SliderFloat("Light Intensity", &intensity, 0, 100);
		ImGui::SliderInt("Max Bounces", &data.max_path_length, 1, 8);
		ImGui::Checkbox("NEE", &nee);
		ImGui::Checkbox("BRDF", &brdfSampling);
		ImGui::Checkbox("MIS", &mis);
	}

	Vec3fa sampleUniformHemisphere(const Vec2f& s, const Vec3fa& N);

    void initScene() override;

    void standardScene();

    void veachScene();

    float colorLight[3] = {1.0f, 1.0f, 1.0f};

	
	float intensity = 1.f;
	bool nee = false;
	bool brdfSampling = false;
	bool mis = false;
};
