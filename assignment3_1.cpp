#include <complex>
#include <deque>

#include "stdafx.h"
#include <stdint.h>
#include <functional>
#include <random>
#include <glm/gtx/rotate_vector.hpp>

#include "tornado.hpp"

char applicationTitle[128] = "Stream Tubes and Ribbons";

const char path2Demo[] = "Assignments/Assignment3/";

using namespace glm;

#ifdef USE_TWEAK_BAR
TwBar* bar = NULL;

double ms_moment1 = 0;
double ms_moment2 = 0;
double ms_samples = 0;
double g_mean = 0;
double g_variance = 0;

float h = 0.02;
float h_prev = -1;
float timeStep = 2;
float timeStep_prev = -1;
int numLines = 1;
int numLines_prev = -1;
int g_task = 1;
int g_prev_task = -1;
bool wireframe = false;
float g_width = 0.01;
float g_widthTube = 0.01;
int g_sides = 6;
bool variable_width = false;

void initializeTweakBar() {
    if (bar != NULL)
        TwDeleteBar(bar);
    else
        TwTerminate();
    nTweakBarVariables = 0;

    // create a tweak bar
    TwDefine("GLOBAL fontscaling=1");
    TwInit(TW_OPENGL, NULL);
    TwDefine("GLOBAL fontsize=3");

    bar = TwNewBar("Stream*");

    TwDefine("'Stream*' position='8 30'");
    TwDefine("'Stream*' size='400 500'");

    TwEnumVal tasks[3] = {{1, "Streamline"}, {2, "Stream Tube"}, {3, "Stream Ribbon"}};
    TwType tm1 = TwDefineEnum("Task", tasks, 3);
    TwAddVarRW(bar, "Mode (m)", tm1, &g_task, "  keyIncr='m' keyDecr='M' ");

    TwAddVarRW(bar, "h", TW_TYPE_FLOAT, &h, " min=0.01 max=1.0 step=0.01 label='step size'");
    TwAddVarRW(bar, "timeStep", TW_TYPE_FLOAT, &timeStep, " min=0.0 max=100.0 step=0.1 label='time step'");
    TwAddVarRW(bar, "numLines", TW_TYPE_INT32, &numLines, " min=1 max=100 step=1 label='number of lines'");

    TwAddVarRW(bar, "wireframe", TW_TYPE_BOOL32, &wireframe, "label='Wireframe'");

    TwAddVarRW(bar, "widthRibbon", TW_TYPE_FLOAT, &g_width, " min=0.01 max=1.0 step=0.01 label='ribbon width'");

    TwAddVarRW(bar, "widthTube", TW_TYPE_FLOAT, &g_widthTube, " min=0.01 max=1.0 step=0.01 label='tube width'");
    TwAddVarRW(bar, "sides", TW_TYPE_INT32, &g_sides, " min=1 max=20 step=1 label='tube sides'");

    TwAddVarRW(bar, "ms_mean", TW_TYPE_DOUBLE, &g_mean, "label='runtime mean (ms)' readonly=true precision=4");
    TwAddVarRW(bar, "ms_variance", TW_TYPE_DOUBLE, &g_variance,
               "label='runtime variance (ms)'  readonly=true precision=4 ");
}
#endif

class CRender : public CRenderBase {
protected:
    Camera camera;
    // GLSLProgram prgRenderStream; // GLSL programs, each one can keep a vertex and a fragment shader
    GLSLProgram prgRenderRibbon; // GLSL programs, each one can keep a vertex and a fragment shader
    GLSLProgram prgRenderTube; // GLSL programs, each one can keep a vertex and a fragment shader
    GLSLProgram prgRenderLine; // GLSL programs, each one can keep a vertex and a fragment shader

    IMWrap wrap; // wrapper for OpenGL immediate calls

    std::vector<std::deque<vec3> > streamlines = {};
    std::vector<glm::vec3> colors = {};
    std::vector<glm::vec3> seeds = {};

public:
    CRender() {
        glfwGetWindowSize(glfwWindow, &width, &height);

        // called here as the initialization depends on some flags we can set in CRender (not used here)
        CRenderBase::CRenderBaseInit();

        // load and/or create shaders, textures, and models
        loadShaders(true);
        createTextures();

        // call it here so that these textures show up at the end in the texture manager
        CRenderBase::createTextures();
    }

    ~CRender() {
    }

    void measurement_reset() {
        ms_moment1 = 0;
        ms_moment2 = 0;
        ms_samples = 0;
    }

    std::pair<double, double> with_measurement(std::function<void()> fn) {
        GLuint64 startTime, stopTime;
        unsigned int queryID[2];
        glGenQueries(2, queryID);
        glQueryCounter(queryID[0], GL_TIMESTAMP);
        fn();
        glQueryCounter(queryID[1], GL_TIMESTAMP);
        GLint stopTimerAvailable = 0;
        while (!stopTimerAvailable) {
            glGetQueryObjectiv(queryID[1],
                               GL_QUERY_RESULT_AVAILABLE,
                               &stopTimerAvailable);
        }
        glGetQueryObjectui64v(queryID[0], GL_QUERY_RESULT, &startTime);
        glGetQueryObjectui64v(queryID[1], GL_QUERY_RESULT, &stopTime);

        double ms = (stopTime - startTime) / 1000000.0;
        ms_moment1 += ms;
        ms_moment2 += (ms * ms);
        ms_samples++;
        g_mean = (ms_moment1 / ms_samples);
        g_variance = (ms_moment2 / ms_samples) - g_mean * g_mean;
        return {g_mean, g_variance};
    }

    void loadModelsLine() {
        // binding of shader and wrapper: 2 attributes which are named in_position and in_color in the vertex shader
        wrap.bindShader(prgRenderLine.getProgramObject(), 2, "in_position", "in_color");
        wrap.Begin(GL_LINE_STRIP);
        for (int i = 0; i < streamlines.size(); ++i) {
            for (auto& point: streamlines[i]) {
                auto color = colors[i];
                wrap.Attrib3f(1, color.x, color.y, color.z);
                wrap.Vertex3f(point.x, point.y, point.z); // alternatively: Attrib3f( 0, x, y, z ) followed by emitVertex();
            }
        }
        wrap.End();
    }

    void loadModelsTube() {
        // TODO upload the relevant data for tube construction
        wrap.bindShader(prgRenderTube.getProgramObject(), 2, "in_position", "in_color");
        wrap.Begin(GL_LINE_STRIP);
        for (int i = 0; i < streamlines.size(); ++i) {
            for (auto& point: streamlines[i]) {
                auto color = colors[i];
                wrap.Attrib3f(1, color.x, color.y, color.z);
                wrap.Vertex3f(point.x, point.y, point.z); // alternatively: Attrib3f( 0, x, y, z ) followed by emitVertex();
            }
        }
        wrap.End();
    }

    void loadModelsRibbon() {
        // TODO upload the relevant data for ribbon construction
        wrap.bindShader(prgRenderRibbon.getProgramObject(), 2, "in_position", "in_color");
        wrap.Begin(GL_LINE_STRIP);
        for (int i = 0; i < streamlines.size(); ++i) {
            for (auto& point: streamlines[i]) {
                auto color = colors[i];
                wrap.Attrib3f(1, color.x, color.y, color.z);
                wrap.Vertex3f(point.x, point.y, point.z); // alternatively: Attrib3f( 0, x, y, z ) followed by emitVertex();
            }
        }
        wrap.End();
    }

    //
    // load vertex and fragment shaders
    //
    void loadShaders(bool firstTime = false) {
        measurement_reset();

        // TODO change if compute shaders used
        // load and setup shaders
        if (!prgRenderLine.loadVertexShader(tmpStrCat(path2Demo, "shader/streamline.vp.glsl")) ||
            !prgRenderLine.loadFragmentShader(tmpStrCat(path2Demo, "shader/streamline.fp.glsl")) ||
            !prgRenderTube.loadVertexShader(tmpStrCat(path2Demo, "shader/streamtube.vp.glsl")) ||
            !prgRenderTube.loadGeometryShader(tmpStrCat(path2Demo, "shader/streamtube.gs.glsl")) ||
            !prgRenderTube.loadFragmentShader(tmpStrCat(path2Demo, "shader/streamtube.fp.glsl")) ||
            !prgRenderRibbon.loadVertexShader(tmpStrCat(path2Demo, "shader/streamribbon.vp.glsl")) ||
            !prgRenderRibbon.loadGeometryShader(tmpStrCat(path2Demo, "shader/streamribbon.gs.glsl")) ||
            !prgRenderRibbon.loadFragmentShader(tmpStrCat(path2Demo, "shader/streamribbon.fp.glsl"))) {
            if (firstTime) exit(1);
        }

        prgRenderLine.link();
        prgRenderTube.link();
        prgRenderRibbon.link();
        glBindFragDataLocation(prgRenderLine.getProgramObject(), 0, "out_color");
        glBindFragDataLocation(prgRenderTube.getProgramObject(), 0, "out_color");
        glBindFragDataLocation(prgRenderRibbon.getProgramObject(), 0, "out_color");
#ifdef USE_TWEAK_BAR
        if (firstTime) {
            initializeTweakBar();

            // parse the shader for UI-variables, add them to AntTweakBar in section 'auto-gen variables'
            parseShaderTweakBar(bar, &prgRenderLine, prgRenderTube.getFragmentShaderSrc(), "auto-gen variables");
            parseShaderTweakBar(bar, &prgRenderTube, prgRenderTube.getFragmentShaderSrc(), "auto-gen variables");
            parseShaderTweakBar(bar, &prgRenderRibbon, prgRenderRibbon.getFragmentShaderSrc(), "auto-gen variables");
        }
#endif
    }

    void calculateSeeds() {
        colors = std::vector<glm::vec3>(numLines);
        seeds = std::vector<glm::vec3>(numLines);
        std::mt19937_64 rng;

        unsigned int seed = 25;
        std::seed_seq ss{seed & 0xffffffff, seed >> 32};
        rng.seed(ss);
        // initialize a uniform distribution between 0 and 1
        std::uniform_real_distribution<double> unif(0.2, 0.8);

        for (int i = 0; i < numLines; ++i) {
            colors[i] = {unif(rng), unif(rng), unif(rng)};
            seeds[i] = {unif(rng), unif(rng), unif(rng)};
        }
    }

    vec3 circleField(const vec3& pos, float zDir) {
        return {-pos.z, zDir, pos.x};
    }

    void calculateStreamlines() {
        streamlines = {};
        // TODO change to proper integration end with bounded vector field
        int maxSteps = 20;

        for (int i = 0; i < numLines; ++i) {
            vec3 back_pos = seeds[i];
            vec3 front_pos = seeds[i];

            // rescale from [0,1]^3 to [-1,1]^3
            std::deque<vec3> line = {back_pos * 2.f - 1.f};

            for(int step = 0; step < maxSteps; ++step) {
                vec3 newpos = back_pos + h*vec3(1,0,0);
                vec3 newposFront = front_pos - h*vec3(1,0,0);

                // rescale from [0,1]^3 to [-1,1]^3
                line.push_back(newpos * 2.f - 1.f);
                line.push_front(newposFront * 2.f - 1.f);

                back_pos = newpos;
                front_pos = newposFront;
            }
            // end line with nan vec (OpenGL rejects the vertex and starts a new line strip)
            line.push_back(vec3(NAN,NAN,NAN));
            streamlines.push_back(line);
        }
    }

    void createTextures() {
    }

    void sceneRenderFrame(int invocation = 0) {
        bool new_timeStep = timeStep != timeStep_prev;
        bool new_stepsize = h != h_prev;
        bool new_lines = numLines != numLines_prev;
        bool new_task = g_task != g_prev_task;
        timeStep_prev = timeStep;
        h_prev = h;
        numLines_prev = numLines;
        g_prev_task = g_task;

        if (new_stepsize || new_timeStep || new_lines || new_task) {
            measurement_reset();
            if (new_lines) {
                calculateSeeds();
            }
            calculateStreamlines();
            switch (g_task) {
                case 1: {
                    loadModelsLine();
                    break;
                }
                case 2: {
                    // TODO compute relevant data
                    loadModelsTube();
                    break;
                }
                case 3: {
                    // TODO compute relevant data
                    loadModelsRibbon();
                    break;
                }
                default: assert(false);
            }
        }


        glClearColor(0.3f, 0.3f, 0.3f, 0.2f); // clear screen
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        glEnable(GL_DEPTH_TEST); // set some render states
        glDisable(GL_BLEND);
        glDisable(GL_CULL_FACE);
        if (wireframe) {
            glPolygonMode(GL_FRONT_AND_BACK, GL_LINE);
        } else {
            glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
        }


        switch (g_task) {
            case 1: {
                prgRenderLine.bind(); // now bind the program and set the uniform parameters

                mat4 matM;
                camera.computeMatrices(&trackball, matM, 0); // computeMatrices has to be called, matM not used here

                prgRenderLine.UniformMatrix4fv((char const *) "matMVP", 1,
                                               false, value_ptr(camera.matMVP));
                break;
            }
            case 2: {
                prgRenderTube.bind(); // now bind the program and set the uniform parameters

                mat4 matM;
                camera.computeMatrices(&trackball, matM, 0); // computeMatrices has to be called, matM not used here

                prgRenderTube.Uniform1f((char const *) "sides", (float) g_sides);
                prgRenderTube.Uniform1f((char const *) "width", g_widthTube);
                prgRenderTube.UniformMatrix4fv((char const *) "matMVP", 1,
                                               false, value_ptr(camera.matMVP));
                prgRenderTube.Uniform3fv((char const *) "camPos", 1,
                                         value_ptr(camera.camPos));
                break;
            }
            case 3: {
                prgRenderRibbon.bind(); // now bind the program and set the uniform parameters

                mat4 matM;
                camera.computeMatrices(&trackball, matM, 0); // computeMatrices has to be called, matM not used here

                prgRenderRibbon.Uniform1f((char const *) "width", g_width);
                prgRenderRibbon.UniformMatrix4fv((char const *) "matMVP", 1,
                                                 false, value_ptr(camera.matMVP));
                prgRenderTube.Uniform3fv((char const *) "camPos", 1,
                                         value_ptr(camera.camPos));
                break;
            }
            default: assert(false);
        }
#ifdef USE_TWEAK_BAR
        setShaderUniformsTweakBar(); // set uniforms of automatically generated UI elements
#endif
        with_measurement([&] { wrap.draw(); });
        renderGrid(&camera); // render grid + axis widget
    }
};

// no need to modify anything below this line
CRender* pRenderClass;

void initialize() {
    pRenderClass = new CRender();
}
