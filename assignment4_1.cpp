/*
________             _____      ________________________
    ___  __ \______________  /________  ____/__  /___  ____/
    __  /_/ /_  ___/  __ \  __/  __ \  / __ __  / __  /_
    _  ____/_  /   / /_/ / /_ / /_/ / /_/ / _  /___  __/
    /_/     /_/    \____/\__/ \____/\____/  /_____/_/

   ___/ minimalistic prototyping framework for OpenGL demos and practical courses
   ___/ Carsten Dachsbacher
   ___/ (ASCII font generator: http://patorjk.com/software/taag/)
*/


#define USE_TWEAK_BAR

#include "stdafx.h"
#include "molecule_reader.hpp"

char applicationTitle[128] = "SES";

const char path2Demo[] = "Assignments/Assignment4/";

std::vector<std::string> dataset_paths {
    "data/molecule/single_atom.raw",
    "data/molecule/basic_cases.raw",
    "data/molecule/ethanol.raw",
    "data/molecule/1bl1.raw",
    "data/molecule/1mbo.raw",
};

using namespace glm;

TwBar* bar = NULL; // Pointer to a tweak bar

vec4 g_ObjectRotation = vec4(0, 0, 0, 1);
vec3 g_BackgroundColor = vec3(1.0f, 1.0f, 1.0f);

float g_Exposure = 0.0f, g_Gamma = 1.0f;

int g_dataset_idx = 0; int g_dataset_idx_prev = -1;
int g_max_atom_count = 2048;
int g_atom_count = 0;
bool g_use_implicit_SES = false;
bool g_use_acceleration_structure = false;
float g_atom_radius = 0.1f; float g_atom_radius_prev = -1.f;
float g_solvent_radius = 0.05f; float g_solvent_radius_prev = -1.f;


void initializeTweakBar() {
    if (bar != NULL)
        TwDeleteBar(bar);
    else
        TwTerminate();
    nTweakBarVariables = 0;

    // Create a tweak bar
    TwDefine("GLOBAL fontscaling=1");
    TwInit(TW_OPENGL, NULL);
    TwDefine("GLOBAL fontsize=3");

    bar = TwNewBar("SES");
    TwDefine("'SES' position='8 30'");
    TwDefine("'SES' size='400 500'");
    TwDefine("'SES' text=light");

    TwEnumVal datasets[5] = {{0, "Single Atom"}, {1, "Basic Cases"}, {2, "Ethanol"}, {3, "Amino Acid"}, {4, "Oxymyoglobin"}};
    // WARNING: Amino Acid and Oxymyoglobin are very large data sets and expensive to render
    TwType tm2 = TwDefineEnum("Dataset", datasets, 5);
    TwAddVarRW(bar, "Dataset [d]", tm2, &g_dataset_idx, "  keyIncr='d' keyDecr='D' ");
    TwAddVarRW(bar, "max. atom count", TW_TYPE_INT32, &g_max_atom_count, "min=1 max=1024 label='max. number of atoms to load'");
    TwAddVarRW(bar, "atom count", TW_TYPE_INT32, &g_atom_count, "label='number of atoms' readonly=true");

    TwAddVarRW(bar, "Render SES surface", TW_TYPE_BOOL32, &g_use_implicit_SES, "group='SES Rendering'");
    TwAddVarRW(bar, "acceleration grid", TW_TYPE_BOOL32, &g_use_acceleration_structure, "group='SES Rendering' readonly=true");
    TwAddVarRW(bar, "atom radius (r)", TW_TYPE_FLOAT, &g_atom_radius, "min=0.001f max=.1 step=0.001f group='SES Rendering'");
    TwAddVarRW(bar, "solvent radius (R)", TW_TYPE_FLOAT, &g_solvent_radius, "min=0.001f max=.1 step=0.001f group='SES Rendering'");

    TwAddVarRW(bar, "light", TW_TYPE_QUAT4F, (float *) &g_ObjectRotation, "group='Display'");
    TwAddVarRW(bar, "background", TW_TYPE_COLOR3F, (float *) &g_BackgroundColor, "group='Display'");
    TwAddVarRW(bar, "exposure", TW_TYPE_FLOAT, &g_Exposure, " min=-4.0 max=4.0 step=0.01 group='Display'");
    TwAddVarRW(bar, "gamma", TW_TYPE_FLOAT, &g_Gamma, " min=1.0 max=3.0 step=0.01 group='Display'");
}


class CRender : public CRenderBase {
protected:
    Scene* scene;
    Camera camera;
    GLSLProgram prgRenderSES; // GLSL programs, each one can keep a vertex and a fragment shader
    IMWrap wrap; // wrapper for OpenGL immediate calls

    // SSBOs containing the atom positions as vec4[]
    GLuint ssbo_atom_positions = GL_INVALID_VALUE;
    std::vector<glm::vec4> atom_positions;

    int sampleIdx;

    bool mouseUpdate;
    int lastMouseX, lastMouseY;
    float mouseXPos, mouseYPos;

    bool shaderUpdate;

public:
    CRender() {
        glfwGetWindowSize(glfwWindow, &width, &height);

        offScreenRenderTarget = false; // required for multi sampling, stereo, accumulation
        useMultisampling = false;
        stereoRendering = false;
        useAccumulationBuffer = false; // call clearAccumulationBuffer(); in sceneFrameRender() to clear the buffer
        //accumulationEWA		  = 0.04f;		// if this value is set (to != 1.0f which is default) then accumulation buffer images will be accumulated using exponentially weighted averaging
        enableGLDebugOutput = true;

        // called here as the initialization depends on some flags we can set in CRender
        CRenderBase::CRenderBaseInit();

        // load and/or create shaders, textures, and models
        loadShaders(true);
        createTextures();
        loadModels();

        // call it here so that these textures show up at the end in the texture manager
        CRenderBase::createTextures();
    }

    ~CRender() {
        delete scene;
    }

    //
    // load 3d models
    //
    void loadModels() {
        scene = new Scene(texMan);
        // unit cube encapsulating the molecule positions
        const char* attribs[3] = {"in_position", "in_normal", "in_texcoord"};
        mat4x4 matrix = rotate(mat4(1.0f), radians(-90.0f), vec3(1.0f, 0.0f, 0.0f));
        scene->loadOBJ(SCENE_SMOOTH, prgRenderSES.getProgramObject(), 3, (const char **) attribs, "box.obj", "./data/",
                       true, &matrix);

        // molecule data (atom positions)
        molecule_read(dataset_paths.at(g_dataset_idx), atom_positions, g_max_atom_count);
        g_atom_count = atom_positions.size();
        //molecule_debugprint(atom_positions)

        // set atom and solvent radius to some reasonable values
        float atom_count_per_dim = glm::pow(static_cast<float>(g_atom_count), 1.f/3.f);
        g_atom_radius = glm::clamp(0.08f / atom_count_per_dim, 0.001f, 0.1f);
        g_solvent_radius = glm::clamp(0.04f / atom_count_per_dim, 0.001f, 0.1f);
    }


    void rebuildAccelerationStructure(float cell_size) {
        // TODO: Bonus Task of Assignment 4 (remove readonly=true from the TW parameter "acceleration grid")
    }

    void allocateComputeStorage() {
        // atom positions
        if(ssbo_atom_positions != GL_INVALID_VALUE) {
            glDeleteBuffers(1, &ssbo_atom_positions);
        }
        glGenBuffers(1, &ssbo_atom_positions);
        glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo_atom_positions);
        glBufferStorage(GL_SHADER_STORAGE_BUFFER, atom_positions.size() * sizeof(vec4), atom_positions.data(), 0);
        assert(!glGetError());

        // TODO: Bonus Task of Assignment 4 (remove readonly=true from the TW parameter "acceleration grid")
    }


    //
    // load vertex and fragment shaders
    //
    void loadShaders(bool firstTime = false) {
#ifdef USE_TWEAK_BAR
        initializeTweakBar();
#endif

        if (!firstTime) CRenderBase::loadShaders(firstTime);

        // load and setup a shader
        if (!prgRenderSES.loadVertexShader(tmpStrCat(path2Demo, "shader/ses.vp.glsl")) ||
            !prgRenderSES.loadFragmentShader(tmpStrCat(path2Demo, "shader/ses.fp.glsl"))) {
            if (firstTime) exit(1);
        }

        prgRenderSES.link();
        glBindFragDataLocation(prgRenderSES.getProgramObject(), 0, "out_color");


        // parse the shader for UI-variables, add them to AntTweakBar in section 'Lighting'
#ifdef USE_TWEAK_BAR
        parseShaderTweakBar(bar, &prgRenderSES, prgRenderSES.getFragmentShaderSrc(), "Shader Parameters");
#endif
    }

    //
    // create textures and render targets
    //
    void createTextures() {
    }


    bool mouseFunc(int button, int state, int x, int y, int mods) {
        return CRenderBase::mouseFunc(button, state, x, y, mods);
    }

    bool mouseMotion(int x, int y) {
        mouseXPos = (float) x / (float) width;
        mouseYPos = (float) y / (float) height;
        if (lastMouseX != x || lastMouseY != y) {
            mouseUpdate = true;
            lastMouseX = x;
            lastMouseY = y;
        }

        return CRenderBase::mouseMotion(x, y);
    }

    //
    // render a frame of the scene (multiple invocations possible for accumulation buffers or stereo-/multi-view-rendering; just ignore if not required)
    //
    void sceneRenderFrame(int invocation = 0) {

        // possibly reload molecule data set
        bool new_dataset = g_dataset_idx != g_dataset_idx_prev;
        if(new_dataset) {
            loadModels();
            g_dataset_idx_prev = g_dataset_idx;
        }

        // update acceleration structure when atom / solvent radii change, or when a new data set is loaded
        bool rebuild_acceleration_structure = g_use_acceleration_structure
                                            && (g_atom_radius_prev != g_atom_radius || g_solvent_radius != g_solvent_radius_prev)
                                            || new_dataset;
        if(rebuild_acceleration_structure) {
            // TODO: Bonus Task of Assignment 4 (remove readonly=true from the TW parameter "acceleration grid")
        }

        // (re-)create and upload GPU buffers
        if(new_dataset || rebuild_acceleration_structure) {
            allocateComputeStorage();
        }

        // set some render states
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

        // clear screen
        glClearColor(g_BackgroundColor.x, g_BackgroundColor.y, g_BackgroundColor.z, 0.2f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        if (useAccumulationBuffer) {
            if (trackball.hasUpdated() || shaderUpdate || mouseUpdate) {
                clearAccumulationBuffer();
                sampleIdx = 1;
                shaderUpdate = false;
                mouseUpdate = false;
            } else
                sampleIdx++;
        } else
            sampleIdx = 1;

        // now bind the program and set the parameters
        bool bindRet = prgRenderSES.bind();
        assert(bindRet && "could not bind program");

        assert(ssbo_atom_positions != GL_INVALID_VALUE);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, ssbo_atom_positions);
        prgRenderSES.Uniform1i((char const *) "atom_count", static_cast<int>(atom_positions.size()));
        prgRenderSES.Uniform1i((char const *) "use_implicit_SES", static_cast<int>(g_use_implicit_SES));
        prgRenderSES.Uniform1i((char const *) "use_acceleration_structure", static_cast<int>(g_use_acceleration_structure));
        if(g_use_acceleration_structure) {
            // TODO: Bonus Task of Assignment 4 (remove readonly=true from the TW parameter "acceleration grid")
        }

        // set SES rendering uniforms
        prgRenderSES.Uniform1f((char const *) "atom_radius", static_cast<float>(g_atom_radius));
        prgRenderSES.Uniform1f((char const *) "solvent_radius", static_cast<float>(g_solvent_radius));

#ifdef USE_TWEAK_BAR
        setShaderUniformsTweakBar();
#endif

        mat4 matM, matNrml;
        camera.computeMatrices(&trackball, matM, 0);
        matNrml = transpose(inverse(matM));

        prgRenderSES.UniformMatrix4fv((char *) "matM", 1, false, value_ptr(matM));
        prgRenderSES.UniformMatrix4fv((char *) "matNrml", 1, false, value_ptr(matNrml));

        prgRenderSES.UniformMatrix4fv((char *) "matMV", 1, false, value_ptr(camera.matMV));
        prgRenderSES.UniformMatrix4fv((char *) "matVP", 1, false, value_ptr(camera.matVP));
        prgRenderSES.UniformMatrix4fv((char *) "matV", 1, false, value_ptr(camera.matV));
        prgRenderSES.UniformMatrix4fv((char *) "matMVP", 1, false, value_ptr(camera.matMVP));

        prgRenderSES.Uniform3fv((char *) "camPos", 1, value_ptr(camera.camPos));
        prgRenderSES.Uniform1f((char *) "time", (float) rand() / 32767.0f);

        glm::quat quat = glm::quat(g_ObjectRotation.w, g_ObjectRotation.x, g_ObjectRotation.y, g_ObjectRotation.z);
        vec3 lightPos = normalize(glm::vec3((glm::toMat4(quat)[0])));
        prgRenderSES.Uniform3fv((char *) "lightPos", 1, value_ptr(lightPos));
        prgRenderSES.Uniform3fv((char *) "bgColor", 1, value_ptr(g_BackgroundColor));

        // mouseXPos could be used in fragment shader for split screen between different render modes
        prgRenderSES.Uniform1f((char const *) "mouseXPos", mouseXPos);
        prgRenderSES.Uniform1f((char const *) "mouseYPos", mouseYPos);

        // display widget
        scene->draw(&prgRenderSES, 0);

        setExposureGamma(g_Exposure, g_Gamma);
    }
};

// no need to modify anything below this line

CRender* pRenderClass;

void initialize() {
    pRenderClass = new CRender();
}
