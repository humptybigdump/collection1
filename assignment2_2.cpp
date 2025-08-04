#include "stdafx.h"
#include <stdint.h>
#include <functional>
#include "tetrahedra_reader.hpp"
#include "interval_tree.hpp"

char applicationTitle[128] = "Marching Tetrahedra";

const char path2Demo[] = "Assignments/Assignment2/";

std::vector<std::string> dataset_paths {
    "data/tet/minigradient.raw",
    "data/tet/nucleon.raw",
    "data/tet/damavand_volcano.raw",
};

using namespace glm;

#ifdef USE_TWEAK_BAR
TwBar *bar = NULL;

float g_isovalue = 0.5f; float g_isovalue_prev = -1;
int g_task = 1; int g_prev_task = -1;
int g_dataset_idx = 0; int g_dataset_idx_prev = -1;
double ms_moment1 = 0;
double ms_moment2 = 0;
double ms_samples = 0;
double g_mean = 0;
double g_variance = 0;
int g_tets_overall = 0;
int g_tets_submitted = 0;

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

    bar = TwNewBar("Marching-*");

    TwDefine("'Marching-*' position='8 30'");
    TwDefine("'Marching-*' size='400 500'");

    TwEnumVal tasks[3] = {{1, "Task 1: Brute Force"}, {2, "Task 2: Compute Triangulation"}, {3, "Task 3: Interval Tree"}};
    TwType tm1 = TwDefineEnum("Task", tasks, 3);
    TwAddVarRW(bar, "Mode (m)", tm1, &g_task, "  keyIncr='m' keyDecr='M' ");

    TwEnumVal datasets[3] = {{0, "Minigradient"}, {1, "Nucleon"}, {2, "Damavand Volcano"}};
    TwType tm2 = TwDefineEnum("Dataset", datasets, 3);
    TwAddVarRW(bar, "Dataset (d)", tm2, &g_dataset_idx, "  keyIncr='d' keyDecr='D' ");

    TwAddVarRW(bar, "isovalue", TW_TYPE_FLOAT, &g_isovalue, " min=0.0 max=1.0 step=0.01 label='isovalue'");

    TwAddVarRW(bar, "ms_mean", TW_TYPE_DOUBLE, &g_mean, "label='runtime mean (ms)' readonly=true precision=4");
    TwAddVarRW(bar, "ms_variance", TW_TYPE_DOUBLE, &g_variance, "label='runtime variance (ms)'  readonly=true precision=4 ");

    TwAddVarRW(bar, "tets_count", TW_TYPE_INT32, &g_tets_overall, "label='tetrahedra in dataset' readonly=true");
    TwAddVarRW(bar, "tets_culled_cnt", TW_TYPE_INT32, &g_tets_submitted, "label='tetrahedra submitted'  readonly=true");

}
#endif


class CRender : public CRenderBase {
protected:
    Camera camera;
    GLSLProgram prgRenderTetrahedra; // GLSL programs, each one can keep a vertex and a fragment shader
    GLSLProgram prgCullTetrahedra;
    GLSLProgram prgRenderTriangles;
    IMWrap wrap; // wrapper for OpenGL immediate calls

    // SSBOs for task 2. compute reads from these.
    // Note that `wrap` also contains a GPU buffer of tetrahedra. It's decoupled to let you play with custom compression techniques!
    GLuint ssbo_tetrahedra = GL_INVALID_VALUE;
    GLuint ssbo_triangle_vertices = GL_INVALID_VALUE;
    GLuint ssbo_triangle_normals = GL_INVALID_VALUE;

    std::vector<tetrahedron_t> tets;
    std::shared_ptr<interval_tree_t> interval_tree = nullptr;
    uint32_t num_triangles;

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

    std::pair<double,double> with_measurement(std::function<void()> fn) {
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

        double ms = (stopTime-startTime)/1000000.0;
        ms_moment1 += ms;
        ms_moment2 += (ms*ms);
        ms_samples++;
        g_mean = (ms_moment1/ms_samples);
        g_variance = (ms_moment2/ms_samples) - g_mean*g_mean;
        return { g_mean, g_variance };
    }

    void loadModels() {
        interval_tree = nullptr;
        // binding of shader and wrapper: 4 attributes for the vertex shader
        wrap.bindShader(prgRenderTetrahedra.getProgramObject(), 4, "in_v0", "in_v1", "in_v2", "in_v3");

        tetrahedra_read(dataset_paths.at(g_dataset_idx), tets);
        g_tets_overall = tets.size();
    }

    void allocateComputeStorage() {
        // upload the raw data to the gpu, reserve enough space to allocate normals and triangle vertices
        // in the worst case!
        if(ssbo_tetrahedra != GL_INVALID_VALUE) {
            glDeleteBuffers(1, &ssbo_tetrahedra);
            glDeleteBuffers(1, &ssbo_triangle_normals);
            glDeleteBuffers(1, &ssbo_triangle_vertices);
        }

        glGenBuffers(1, &ssbo_tetrahedra);
        glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo_tetrahedra);
        glBufferStorage(GL_SHADER_STORAGE_BUFFER, tets.size() * sizeof(tetrahedron_t), tets.data(), GL_DYNAMIC_STORAGE_BIT);
        assert(!glGetError());
        glGenBuffers(1, &ssbo_triangle_normals);
        glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo_triangle_normals);
        // note: vec4 since vec3 is padded with 32bit
        glBufferStorage(GL_SHADER_STORAGE_BUFFER, tets.size() * sizeof(glm::vec4), nullptr,  GL_DYNAMIC_STORAGE_BIT);
        assert(!glGetError());
        glGenBuffers(1, &ssbo_triangle_vertices);
        glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo_triangle_vertices);
        glBufferStorage(GL_SHADER_STORAGE_BUFFER, tets.size() * (/* up to two triangles of 3 vertices each */ 2 * 3 * sizeof(glm::vec4)) + sizeof(glm::vec4), nullptr,  GL_DYNAMIC_STORAGE_BIT | GL_MAP_WRITE_BIT | GL_MAP_READ_BIT);
        assert(!glGetError());
    }

    void recordTetrahedra() {
        if(g_task == 1) {
            // brute force, just record all tetrahedra and send them to the gpu
            wrap.Begin(GL_POINTS); // data of one tetrahedron stores as attributes of a point primitive

            for(tetrahedron_t const& tet : tets) {
                for (int i = 0; i < 4; ++i) {
                    glm::vec4 vertex = tet[i]; // xyz is position, w is scalar field value
                    wrap.Attrib4fv(i,glm::value_ptr(vertex));
                }
                wrap.emitVertex();
            }
            g_tets_submitted = tets.size();
            wrap.End();
        }
        else if (g_task == 2) {
            // use a compute shader to extract the triangle mesh representing the iso surface from the tetrahedra


            { // reset the atomic counter to zero
                glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo_triangle_vertices);
                size_t bytes_to_clear = sizeof(uint32_t) * 2;
                void *ptr = glMapBufferRange(GL_SHADER_STORAGE_BUFFER, 0, bytes_to_clear, GL_MAP_WRITE_BIT |GL_MAP_INVALIDATE_BUFFER_BIT);
                assert(ptr);
                memset(ptr, 0x00, bytes_to_clear);
                glUnmapBuffer(GL_SHADER_STORAGE_BUFFER);
                glMemoryBarrier(GL_ALL_BARRIER_BITS);
            }

           // glUseProgram(prgCullTetrahedra.getProgramObject());
            assert(prgCullTetrahedra.bind());

            glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, ssbo_tetrahedra);
            glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, ssbo_triangle_vertices);
            glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, ssbo_triangle_normals);

            prgCullTetrahedra.Uniform1f((char const *) "isovalue", g_isovalue);
            prgCullTetrahedra.Uniform1ui((char const *) "tet_count", tets.size());

            size_t workgroup_size = 64;
            size_t workgroups = (tets.size() + workgroup_size - 1) / workgroup_size;
            glDispatchCompute(workgroups, 1, 1);
            glMemoryBarrier(GL_ALL_BARRIER_BITS);
            { // read back the atomic counter
                glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo_triangle_vertices);
                uint32_t stats[2];
                glGetBufferSubData(GL_SHADER_STORAGE_BUFFER, 0, 2*sizeof(uint32_t), stats);
                glMemoryBarrier(GL_ALL_BARRIER_BITS);
                num_triangles = stats[1];
                g_tets_submitted = stats[0];
            }
        }
        else if (g_task == 3) {
            // use an interval tree to reduce the tetrahedra. Called each time the iso value changes.
            if(interval_tree == nullptr) {
                interval_tree_builder_t tree_builder;
                for (int i = 0; i < tets.size(); ++i) {
                    tetrahedron_t const& t = tets.at(i);
                    tree_builder.add_primitive(i, {t.at(0).w, t.at(1).w, t.at(2).w, t.at(3).w });
                }
                interval_tree = tree_builder.finalize();
            }

            wrap.Begin(GL_POINTS);
            size_t intersected = 0;
            interval_tree->visit_isovalue(g_isovalue, [&](id_t tet_idx) {
                intersected++;
                tetrahedron_t const& tet = tets.at(tet_idx);
                for (int i = 0; i < 4; ++i) {
                    glm::vec4 vertex = tet[i]; // xyz is position, w is scalar field value
                    wrap.Attrib4fv(i,glm::value_ptr(vertex));
                }
                wrap.emitVertex();
            });
            g_tets_submitted = intersected;
            wrap.End();
        }
    }

    //
    // load vertex and fragment shaders
    //
    void loadShaders(bool firstTime = false) {
        measurement_reset();

        // load and setup shaders
        if (!prgRenderTetrahedra.loadVertexShader(tmpStrCat(path2Demo, "shader/marching.vp.glsl")) ||
            !prgRenderTetrahedra.loadGeometryShader(tmpStrCat(path2Demo, "shader/marching.gs.glsl")) ||
            !prgRenderTetrahedra.loadFragmentShader(tmpStrCat(path2Demo, "shader/marching.fp.glsl")) ||
            !prgRenderTriangles.loadVertexShader(tmpStrCat(path2Demo, "shader/cull.vp.glsl")) ||
            !prgRenderTriangles.loadFragmentShader(tmpStrCat(path2Demo, "shader/marching.fp.glsl")) ||
            !prgCullTetrahedra.loadComputeShader(tmpStrCat(path2Demo, "shader/cull.comp.glsl"))) {
            if (firstTime) exit(1);
        }

        prgCullTetrahedra.link();
        prgRenderTetrahedra.link();
        prgRenderTriangles.link();
        glBindFragDataLocation(prgRenderTetrahedra.getProgramObject(), 0, "out_color");
        glBindFragDataLocation(prgRenderTriangles.getProgramObject(), 0, "out_color");
#ifdef USE_TWEAK_BAR
        if (firstTime) {
            initializeTweakBar();

            // parse the shader for UI-variables, add them to AntTweakBar in section 'auto-gen variables'
            parseShaderTweakBar(bar, &prgRenderTetrahedra, prgRenderTetrahedra.getFragmentShaderSrc(), "auto-gen variables");
            parseShaderTweakBar(bar, &prgCullTetrahedra, prgCullTetrahedra.getComputeShaderSrc(), "auto-gen variables");
        }
#endif
    }

    void createTextures() {
    }

    void sceneRenderFrame(int invocation = 0) {

        // TODO: maybe only compile shaders for current task
        bool new_task = g_task != g_prev_task;
        bool new_dataset = g_dataset_idx != g_dataset_idx_prev;
        bool new_isovalue = g_isovalue_prev != g_isovalue;
        g_prev_task = g_task;
        g_dataset_idx_prev = g_dataset_idx;
        g_isovalue_prev = g_isovalue;

        if(new_task || new_dataset || new_isovalue) {
            measurement_reset();
        }

        if(new_dataset) {
            loadModels();
        }

        if(g_task == 2 && (new_task || new_dataset)) {
            allocateComputeStorage();
        }

        if(new_dataset || new_task || (g_task != 1 && new_isovalue)) {
            // list of primitives to draw changed.
            // for task 2 and task 3 we have to update culling of primitives if the iso value changes.
            recordTetrahedra();
        }

        switch (g_task) {
            case 1:
            case 3: {
                // both tasks already recorded their tetrahedra into `wrap`

                glClearColor(0.3f, 0.3f, 0.3f, 0.2f); // clear screen
                glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

                glEnable(GL_DEPTH_TEST); // set some render states
                glDisable(GL_BLEND);
                glDisable(GL_CULL_FACE);

                prgRenderTetrahedra.bind(); // now bind the program and set the uniform parameters

                prgRenderTetrahedra.Uniform1f((char const *) "isovalue", g_isovalue);

                mat4 matM;
                camera.computeMatrices(&trackball, matM, 0); // computeMatrices has to be called, matM not used here
                prgRenderTetrahedra.UniformMatrix4fv((char const *) "matMVP", 1,
                                           false, value_ptr(camera.matMVP));
                prgRenderTetrahedra.Uniform3fv((char const *) "camPos", 1,
                                     value_ptr(camera.camPos));

#ifdef USE_TWEAK_BAR
                setShaderUniformsTweakBar(); // set uniforms of automatically generated UI elements
#endif

                with_measurement([&] { wrap.draw(); });
                renderGrid(&camera); // render grid + axis widget
                break;
            }
            case 2: {
                // prerecorded its triangle mesh into `ssbo_triangle_vertices`

                glClearColor(0.3f, 0.3f, 0.3f, 0.2f);
                glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

                glEnable(GL_DEPTH_TEST);
                glDisable(GL_BLEND);
                glDisable(GL_CULL_FACE);

                prgRenderTriangles.bind();
                glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 1, ssbo_triangle_vertices);
                glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, ssbo_triangle_normals);
                mat4 matM;
                camera.computeMatrices(&trackball, matM, 0); // computeMatrices has to be called, matM not used here
                prgRenderTriangles.UniformMatrix4fv((char const *) "matMVP", 1,
                                                     false, value_ptr(camera.matMVP));
                prgRenderTriangles.Uniform3fv((char const *) "camPos", 1,
                                               value_ptr(camera.camPos));

#ifdef USE_TWEAK_BAR
                setShaderUniformsTweakBar(); // set uniforms of automatically generated UI elements
#endif

                with_measurement([&] {
                    glDrawArrays(GL_TRIANGLES, /* offset */ 0, num_triangles*3);
                });
                renderGrid(&camera);
                break;
            }
            default: assert(false);
        }
    }
};

// no need to modify anything below this line
CRender *pRenderClass;

void initialize() {
    pRenderClass = new CRender();
}
