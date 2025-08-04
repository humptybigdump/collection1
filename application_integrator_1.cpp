#include "application_integrator.h"





ApplicationIntegrator::ApplicationIntegrator(int argc, char** argv, const std::string& name):
Application(argc, argv, name)
{
	resetRender();
}

void ApplicationIntegrator::drawGUI() {

	bool bDirty = false;

	if (ImGui::Checkbox("Metropolis", &bMetropolis)) {
		resetRender();
	}

	if (bDirty) {
		resetRender();
	}
}


inline float luminance(Vec3fa v) {
	return 0.2126f * v.x + 0.7152f * v.y + 0.0722f * v.z;
}

void ApplicationIntegrator::resetRender() {
	Application::resetRender();
	
	if (bMetropolis) {
		data.film.count = false;	
	}
	else {
		data.film.count = true;
		data.film.scalar = 1.0;
	}
}

void ApplicationIntegrator::render(int* pixels, int width, int height, float time, const ISPCCamera& camera) {
	deviceRender(camera);

	if (!bMetropolis) {
		mcRender(pixels, width, height, time, camera);
	}
	else {
		mltRender(pixels, width, height, time, camera);
	}
}


void ApplicationIntegrator::mltRender(int* pixels, int width, int height, float time, const ISPCCamera& camera) {

	// data.film.scalar = ... use it for setting up the correct normalization coefficient
	// 
	// 
	// you may want to use Distribution1D for the bootstrap
	// d = Distribution1D(float* bis_values, num_bins)
	// float integral = d.funcInt;
	// int index_of_the_sampled_bin = d.SampleDiscrete(rng.get1D());
	assert(0);
}

void ApplicationIntegrator::mcRender(int* pixels, int width, int height, float time, const ISPCCamera& camera) {
	const int numTilesX = (width + TILE_SIZE_X - 1) / TILE_SIZE_X;
	const int numTilesY = (height + TILE_SIZE_Y - 1) / TILE_SIZE_Y;
	parallel_for(size_t(0), size_t(numTilesX * numTilesY), [&](const range<size_t>& range) {
		const int threadIndex = (int)TaskScheduler::threadIndex();
		for (size_t i = range.begin(); i < range.end(); i++)
			renderTile((int)i, threadIndex, pixels, width, height, time, camera, numTilesX, numTilesY);
	});
}


/* renders a single screen tile */
void ApplicationIntegrator::mcRenderTile(int taskIndex, int threadIndex, int* pixels, const unsigned int width,
	const unsigned int height, const float time, const ISPCCamera& camera, const int numTilesX,
	const int numTilesY) {
	const unsigned int tileY = taskIndex / numTilesX;
	const unsigned int tileX = taskIndex - tileY * numTilesX;
	const unsigned int x0 = tileX * TILE_SIZE_X;
	const unsigned int x1 = min(x0 + TILE_SIZE_X, width);
	const unsigned int y0 = tileY * TILE_SIZE_Y;
	const unsigned int y1 = min(y0 + TILE_SIZE_Y, height);

	for (unsigned int y = y0; y < y1; y++)
		for (unsigned int x = x0; x < x1; x++) {
			RandomSamplerWrapper sampler;
			Vec3fa L = Vec3fa(0.0f);

			for (int i = 0; i < data.spp; i++)
			{
				sampler.init(x, y, (data.frame_count) * data.spp + i);

				/* calculate pixel color */
				float fx = x + sampler.get1D();
				float fy = y + sampler.get1D();
				L = L + renderPixel(fx, fy, camera, g_stats[threadIndex], sampler);
			}
			L = L / (float)data.spp;

			/* write color to framebuffer */
			data.film.addSplat(x, y, L);
		}
}