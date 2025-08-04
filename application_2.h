#pragma once
#include <sys/platform.h>
#include <sys/sysinfo.h>
#include <sys/alloc.h>

#include <sys/ref.h>
#include <sys/vector.h>
#include <math/vec2.h>
#include <math/vec3.h>
#include <math/vec4.h>
#include <math/bbox.h>
#include <math/lbbox.h>
#include <math/affinespace.h>
#include <sys/filename.h>
#include <sys/estring.h>
#include <lexers/tokenstream.h>
#include <lexers/streamfilters.h>
#include <lexers/parsestream.h>

#include <sstream>
#include <vector>
#include <memory>
#include <map>
#include <set>
#include <deque>

#include "helper.hpp"

#include <sys/sysinfo.h>

#include <glad/glad.h>
#include <GLFW/glfw3.h>

#include <imgui.h>
#include <imgui_impl_glfw.h>
#include <imgui_impl_opengl3.h>

#include "camera.hpp"
#include "ray.hpp"
#include "random_sampler.hpp"
#include "random_sampler_wrapper.hpp"

class Application {
public:
    Application(int argc, char** argv, const std::string& name);

    virtual ~Application() = default;

    void run();

protected:
    virtual Vec3fa renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSamplerWrapper& sampler) = 0;

    void deviceRender(const ISPCCamera& camera);

    virtual void drawGUI() {
    }

    virtual void initScene() = 0;

    virtual void render(int* pixels, int width, int height, float time, const ISPCCamera& camera);

    void renderTile(int taskIndex, int threadIndex, int* pixels, unsigned int width,
                    unsigned int height,
                    float time, const ISPCCamera& camera, int numTilesX, int numTilesY);

    void initShader();

    void initOpenGL();

    void renderInteractive();

    void displayFunc();

    void renderOpenGl();

    GLFWwindow* createFullScreenWindow();

    GLFWwindow* createStandardWindow(int width, int height);

    void setCallbackFunctions();

    void resize(int width, int height);

    void framebufferSizeCallback(GLFWwindow*, int width, int height);

    void mouseCursorCallback(GLFWwindow*, double xpos, double ypos);

    void mouseButtonCallback(GLFWwindow*, int button, int action, int mods);

    void keyCallback(GLFWwindow*, int key, int scancode, int action, int mods);

    void scrollCallback(GLFWwindow*, double xoffset, double yoffset);


    // it is invoked when the scene changes
    virtual void resetRender() {
		data.accu_count = 0;
		data.film.clear();
    }

    void initRayStats();

    int64_t getNumRays();

    RTCScene convertScene(RenderScene* scene_in) {
        RTCFeatureFlags g_used_features;
        RTCScene scene_out = ConvertScene(g_device, g_render_scene, RTC_BUILD_QUALITY_MEDIUM, RTC_SCENE_FLAG_NONE,
                                          &g_used_features);

        /* commit changes to scene */
        rtcCommitScene(scene_out);

        return scene_out;
    }

    RTCDevice g_device = nullptr;
    GLFWwindow* window;

    unsigned int texture_id = 0;
    unsigned int shaderID = 0;
    unsigned int VAO = 0;
    unsigned int VBO = 0;

    /* framebuffer settings */
    int width = 800;
    int height = 600;
    unsigned int* pixels = nullptr;

    double time0;
    float render_time = 0;
    Averaged<double> avg_render_time = {64, 1.0};
    Averaged<double> avg_frame_time = {64, 1.0};
    Averaged<double> avg_mrayps = {64, 1.0};

    Camera camera;

    int mouseMode = 0;
    double clickX = 0;
    double clickY = 0;

    float speed = 1;
    Vec3f moveDelta = {0, 0, 0};

    RayStats* g_stats = nullptr;

    Data data = {};
    RenderScene* g_render_scene = nullptr;

    bool g_accumulate = true;
    Vec3fa g_accu_vx = Vec3fa(0.0f);
    Vec3fa g_accu_vy = Vec3fa(0.0f);
    Vec3fa g_accu_vz = Vec3fa(0.0f);
    Vec3fa g_accu_p = Vec3fa(0.0f);

#if defined(WORKING_DIR)
    FileName workingDir = FileName(WORKING_DIR);
#else
    FileName workingDir = FileName();
#endif
};
