#pragma once
#include "helper.hpp"
#include "distribution.hpp"



class ApplicationIntegrator: public Application {
public:
	ApplicationIntegrator(int argc, char** argv, const std::string& name);

	virtual ~ApplicationIntegrator() = default;


protected:
	virtual void render(int* pixels, int width, int height, float time, const ISPCCamera& camera) override;
	virtual void drawGUI() override;
	virtual void resetRender() override;


	bool bMetropolis = false;


	void mltRender(int* pixels, int width, int height, float time, const ISPCCamera& camera);

	void mcRender(int* pixels, int width, int height, float time, const ISPCCamera& camera);

	/* renders a single screen tile */
	void mcRenderTile(int taskIndex, int threadIndex, int* pixels, const unsigned int width,
		const unsigned int height, const float time, const ISPCCamera& camera, const int numTilesX,
		const int numTilesY);
};
