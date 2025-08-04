/*
________             _____      ________________________
    ___  __ \______________  /________  ____/__  /___  ____/
    __  /_/ /_  ___/  __ \  __/  __ \  / __ __  / __  /_
    _  ____/_  /   / /_/ / /_ / /_/ / /_/ / _  /___  __/
    /_/     /_/    \____/\__/ \____/\____/  /_____/_/

   ___/ minimalistic prototyping framework for OpenGL demos and practical courses
   ___/ Carsten Dachsbacher
   ___/ (ASCII font generator: http://patorjk.com/software/taag/)

   ___/ simple class to provide camera transformation matrices
*/

#define USE_TWEAK_BAR

#include "stdafx.h"

char applicationTitle[128] = "DVR";

const char path2Demo[] = "Assignments/Assignment1/";

using namespace glm;

TwBar *bar = NULL; // Pointer to a tweak bar

vec4 g_ObjectRotation = vec4(0, 0, 0, 1);
vec3 g_BackgroundColor = vec3(0.0f, 0.0f, 0.0f);

vec3 g_BrushColor = vec3(0.5f, 0.75f, 0.5f);
float g_BrushOpacity = 0.5f;
int g_BrushSize = 32, g_ClearTF = 0, g_ShowTF = 1;

int g_Mode = 0, g_Left = 0, g_Right = 0, g_Progressive = 0, g_Jitter = 0;
float g_Exposure = 0.0f, g_Gamma = 1.0f;

void TW_CALL cbShowTF(void * /*clientData*/) {
    g_ShowTF = 1 - g_ShowTF;
}

void TW_CALL cbClearTF(void * /*clientData*/) {
    g_ClearTF = 1;
}

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

    bar = TwNewBar("DVR");

    TwDefine("'DVR' position='8 30'");
    TwDefine("'DVR' size='400 500'");
    TwDefine("'DVR' text=light");

    TwEnumVal mode[3] = {{0, "raymarching"}, {1, "MC (null collision)"}, {2, "split"}};
    TwType tm = TwDefineEnum("Mode", mode, 3);
    TwAddVarRW(bar, "Mode (m)", tm, &g_Mode, "  keyIncr='m' keyDecr='M' ");

    TwAddVarRW(bar, "progressive (p)", TW_TYPE_BOOL32, &g_Progressive, " keyIncr='p' label='Progressive Update'");
    TwAddVarRW(bar, "light", TW_TYPE_QUAT4F, (float *) &g_ObjectRotation, "");
    TwAddVarRW(bar, "background", TW_TYPE_COLOR3F, (float *) &g_BackgroundColor, "");

    // TF "editor"
    TwAddButton(bar, "show", cbShowTF, NULL, " label='show TF (t)' key='t' group='Transfer Function' ");
    TwAddButton(bar, "clear", cbClearTF, NULL, " label='clear TF' group='Transfer Function' ");
    TwAddVarRW(bar, "color", TW_TYPE_COLOR3F, (float *) &g_BrushColor, "label='brush color' group='Transfer Function'");
    TwAddVarRW(bar, "opacity", TW_TYPE_FLOAT, &g_BrushOpacity,
               " min=0.01 max=1.0 step=0.01 keyIncr='e' keyDecr='d' label='brush opacity (e/d)' group='Transfer Function'");
    TwAddVarRW(bar, "int", TW_TYPE_INT32, &g_BrushSize,
               " min=1 max=64 keyIncr='w' keyDecr='s' label='brush size (w/s)' group='Transfer Function'");

    TwAddVarRW(bar, "exposure", TW_TYPE_FLOAT, &g_Exposure, " min=-4.0 max=4.0 step=0.01 group='Display'");
    TwAddVarRW(bar, "gamma", TW_TYPE_FLOAT, &g_Gamma, " min=1.0 max=3.0 step=0.01 group='Display'");
}


class CRender : public CRenderBase {
protected:
    Scene *scene;
    Camera camera;
    GLSLProgram prgRender; // GLSL programs, each one can keep a vertex and a fragment shader
    OGLTexture *tVolume;

    int sampleIdx;

    bool mouseUpdate;
    int lastMouseX, lastMouseY;
    float mouseXPos, mouseYPos;

    bool shaderUpdate;

    GLSLProgram prgShowTF;
    int tfTexWidth = 512, tfTexHeight = 256;
    int widgetWidth = 512, widgetHeight = 256, widgetPosX, widgetPosY;
    IMWrap wrap;
    OGLTexture *tHistogram, *tTF;
    uint32_t *pCurTF;
    uint8_t mouseButton;

public:
    CRender() : mouseButton(0) {
        glfwGetWindowSize(glfwWindow, &width, &height);

        offScreenRenderTarget = !false; // required for multi sampling, stereo, accumulation
        useMultisampling = false;
        stereoRendering = false;
        useAccumulationBuffer = !false; // call clearAccumulationBuffer(); in sceneFrameRender() to clear the buffer
        enableGLDebugOutput = true;

        // called here as the initialization depends on some flags we can set in CRender
        CRenderBase::CRenderBaseInit();

        widgetPosX = width - widgetWidth;
        widgetPosY = height - widgetHeight;

        // load and/or create shaders, textures, and models
        loadShaders(true);
        createTextures();
        loadModels();

        // call it here so that these textures show up at the end in the texture manager
        CRenderBase::createTextures();
    }

    ~CRender() {
        if (scene) delete scene;
    }

    //
    // load 3d models
    //
    void loadModels() {
        scene = new Scene(texMan);
        const char *attribs[3] = {"in_position", "in_normal", "in_texcoord"};
        mat4x4 matrix = rotate(mat4(1.0f), radians(-90.0f), vec3(1.0f, 0.0f, 0.0f));
        scene->loadOBJ(SCENE_SMOOTH, prgRender.getProgramObject(), 3, (const char **) attribs, "box.obj", "./data/",
                       true, &matrix);

        // binding of shader and wrapper
        wrap.bindShader(prgShowTF.getProgramObject(), 1, "in_position");

        wrap.Begin(GL_TRIANGLES);
        wrap.Vertex3f(0.0f, 0.0f, 0.0f);
        wrap.Vertex3f(1.0f, 0.0f, 0.0f);
        wrap.Vertex3f(0.0f, 1.0f, 0.0f);

        wrap.Vertex3f(1.0f, 0.0f, 0.0f);
        wrap.Vertex3f(1.0f, 1.0f, 0.0f);
        wrap.Vertex3f(0.0f, 1.0f, 0.0f);
        wrap.End();
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
        if (!prgRender.loadVertexShader(tmpStrCat(path2Demo, "shader/compute_pixel.vp.glsl")) ||
            !prgRender.loadFragmentShader(tmpStrCat(path2Demo, "shader/compute_pixel.fp.glsl"))) {
            if (firstTime) exit(1);
        }

        prgRender.link();
        glBindFragDataLocation(prgRender.getProgramObject(), 0, "out_color");

        // load and setup a shader
        if (!prgShowTF.loadVertexShader(tmpStrCat(path2Demo, "shader/show2DTF.vp.glsl")) ||
            !prgShowTF.loadFragmentShader(tmpStrCat(path2Demo, "shader/show2DTF.fp.glsl"))) {
            if (firstTime) exit(1);
        }

        prgShowTF.link();
        glBindFragDataLocation(prgShowTF.getProgramObject(), 0, "out_color");


        // parse the shader for UI-variables, add them to AntTweakBar in secion 'Lighting'
#ifdef USE_TWEAK_BAR
        parseShaderTweakBar(bar, &prgRender, prgRender.getFragmentShaderSrc(), "Parameters");
#endif
    }

    // maps a direction (not necessarily length 1) to octahedron coordinates [0;1]^2
    vec2 direction2octa(const vec3 &dir) {
        vec3 d = dir / dot(vec3(1.0f), abs(dir));

        vec2 uv;
        if (d.z < 0.0f) {
            uv.x = (1 - abs(d.y)) * sign(d.x);
            uv.y = (1 - abs(d.x)) * sign(d.y);
        } else
            uv = vec2(d.x, d.y);

        // mapping to [0;1]^2 texture space
        uv = uv * 0.5f + 0.5f;
        return uv;
    }

    // maps octahedron coordinates [0;1]^2 to direction (non-normalized!)
    vec3 octa2direction(const vec2 &uv) {
        vec2 t = (uv - vec2(0.5f)) * 2.0f;

        vec3 g = vec3(t.x, t.y, 1.0f - fabsf(t.x) - fabsf(t.y));

        if (g.z < 0.0f) {
            g.x = (1.0f - fabsf(t.y)) * sign(t.x);
            g.y = (1.0f - fabsf(t.x)) * sign(t.y);
        }

        return g;
    }

    //
    // create textures and render targets
    //
    void createTextures() {
        texMan->CreateTexture(&tTF, tfTexWidth, tfTexHeight, GL_RGBA, "transfer function");

        texMan->CreateTexture(&tHistogram, tfTexWidth, tfTexHeight, GL_RGBA, "histogram");
        uint32_t *h = new uint32_t[tfTexWidth * tfTexHeight * 4];
        uint32_t *p = h;
        memset(h, 0, tfTexWidth * tfTexHeight * 4);
        tTF->bind();
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tfTexWidth, tfTexHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, (void *) h);
        glGenerateMipmap(GL_TEXTURE_2D);

        unsigned char *vol = new unsigned char[256 * 256 * 256 * 4];
        unsigned char *tmp = new unsigned char[256 * 256 * 256];

        memset(vol, 0, 256 * 256 * 256 * 4);

        const int vx = 103, vy = 94, vz = 161;
        FILE *f = fopen((char *) "./data/volume/tooth_103x94x161_uint8.raw", "rb");

        //const int vx = 256, vy = 256, vz = 256;
        //FILE *f = fopen( (char *)"./data/volume/skull_256x256x256_uint8.raw", "rb" );
        fread(tmp, vx * vy * vz, 1, f);
        fclose(f);

        int cx = (256 - vx) / 2;
        int cy = (256 - vy) / 2;
        int cz = (256 - vz) / 2;

#pragma omp parallel for
        for (int z = 0; z < vz; z++) {
            for (int y = 0; y < vy; y++) {
                for (int x = 0; x < vx; x++) {
                    vec3 gradient = vec3(0);
                    // compute gradient here


                    // store gradient (x, y, z) and volume scalar value (w)
                    vol[(((z + cz) * 256 + (y + cy)) * 256 + (x + cx)) * 4 + 0] = gradient.x;
                    vol[(((z + cz) * 256 + (y + cy)) * 256 + (x + cx)) * 4 + 1] = gradient.y;
                    vol[(((z + cz) * 256 + (y + cy)) * 256 + (x + cx)) * 4 + 2] = gradient.z;
                    vol[(((z + cz) * 256 + (y + cy)) * 256 + (x + cx)) * 4 + 3] = tmp[((z * vy) + y) * vx + x];
                }
            }
        }

        tVolume = new OGLTexture(GL_TEXTURE_3D);
        tVolume->createTexture();
        tVolume->bind();
        glTexImage3D(GL_TEXTURE_3D, 0, GL_RGBA, 256, 256, 256, 0, GL_RGBA, GL_UNSIGNED_BYTE, vol);
        //glGenerateMipmap( GL_TEXTURE_3D );
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT);

        // replace test texture with histogram
        for ( int j = 0; j < tfTexHeight; j++ )
            for ( int i = 0; i < tfTexWidth; i++ )
                *( p ++ ) = 0x01010101 * ( ( i ^ j ) & 255 );

        tHistogram->bind();
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tfTexWidth, tfTexHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, (void *) h);
        glGenerateMipmap(GL_TEXTURE_2D);

        pCurTF = new uint32_t[tfTexWidth * tfTexHeight * 4];
        memset(pCurTF, 0, tfTexWidth * tfTexHeight * 4);

        delete[] tmp;
        delete[] vol;
    }

    bool paintTF(int x, int y) {
        if (g_ShowTF && mouseButton &&
            x >= widgetPosX && x < widgetPosX + widgetWidth &&
            y >= widgetPosY && y < widgetPosY + widgetHeight) {
            int u = (x - widgetPosX) * tfTexWidth / widgetWidth;
            int v = (y - widgetPosY) * tfTexHeight / widgetHeight;

            int brushSX = g_BrushSize;
            int brushSY = g_BrushSize;

            for (int cu = -brushSX; cu < brushSX; cu++)
                for (int cv = -brushSY; cv < brushSY; cv++) {
                    int du = cu + u;
                    int dv = cv + v;

                    if (du >= 0 && du < tfTexWidth && dv >= 0 && dv < tfTexHeight) {
                        float alpha = expf(-(float) (cu * cu + cv * cv) * 4.0f / (float) (g_BrushSize * g_BrushSize)) *
                                      g_BrushOpacity;

                        uint8_t *rgba = (uint8_t *) &pCurTF[du + (tfTexHeight - 1 - dv) * tfTexWidth];
                        vec4 c = vec4(rgba[0], rgba[1], rgba[2], rgba[3]);

                        if (mouseButton == 1)
                            c = mix(c, vec4(g_BrushColor * 255.0f, 255.0f), alpha);
                        else
                            c = mix(c, vec4(0.0f, 0.0f, 0.0f, 0.0f), alpha);

                        rgba[0] = (int) c.x;
                        rgba[1] = (int) c.y;
                        rgba[2] = (int) c.z;
                        rgba[3] = (int) c.w;
                    }
                }
            return true;
        }
        return false;
    }

    bool mouseFunc(int button, int state, int x, int y, int mods) {
        if (g_ShowTF &&
            x >= widgetPosX && x < widgetPosX + widgetWidth &&
            y >= widgetPosY && y < widgetPosY + widgetHeight) {
            if (button == GLFW_MOUSE_BUTTON_LEFT && state == GLFW_PRESS) mouseButton |= 1;
            if (button == GLFW_MOUSE_BUTTON_RIGHT && state == GLFW_PRESS) mouseButton |= 2;
            paintTF(x, y);
        }
        if (button == GLFW_MOUSE_BUTTON_LEFT && state == GLFW_RELEASE) mouseButton &= ~1;
        if (button == GLFW_MOUSE_BUTTON_RIGHT && state == GLFW_RELEASE) mouseButton &= ~2;
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

        if (g_ShowTF && paintTF(x, y)) return true;

        return CRenderBase::mouseMotion(x, y);
    }

    //
    // render a frame of the scene (multiple invocations possible for accumulation buffers or stereo-/multi-view-rendering; just ignore if not required)
    //
    void sceneRenderFrame(int invocation = 0) {
        // set some render states
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);

        // clear screen
        glClearColor(g_BackgroundColor.x, g_BackgroundColor.y, g_BackgroundColor.z, 0.2f);

        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        if (useAccumulationBuffer) {
            if (trackball.hasUpdated() || shaderUpdate || !g_Progressive || mouseUpdate) {
                clearAccumulationBuffer();
                sampleIdx = 1;
                shaderUpdate = false;
                mouseUpdate = false;
            } else
                sampleIdx++;
        } else
            sampleIdx = 1;

        static int _sampleIdx = 0;
        _sampleIdx++;

        // now bind the program and set the parameters
        prgRender.bind();

#ifdef USE_TWEAK_BAR
        setShaderUniformsTweakBar();
#endif

        BINDOGLTEX(prgRender, "tVolume", tVolume, GL_TEXTURE0);
        BINDOGLTEX(prgRender, "tTF", tTF, GL_TEXTURE1);

        glActiveTexture(GL_TEXTURE0);

        mat4 matM;
        camera.computeMatrices(&trackball, matM, 0);
        prgRender.UniformMatrix4fv((char *) "matM", 1, false, value_ptr(matM));

        prgRender.UniformMatrix4fv((char *) "matMVP", 1, false, value_ptr(camera.matMVP));

        prgRender.Uniform3fv((char *) "camPos", 1, value_ptr(camera.camPos));
        prgRender.Uniform1f((char *) "time", (float) rand() / 32767.0f);

        glm::quat quat = glm::quat(g_ObjectRotation.w, g_ObjectRotation.x, g_ObjectRotation.y, g_ObjectRotation.z);
        vec3 lightPos = normalize(glm::vec3((glm::toMat4(quat)[0])));
        prgRender.Uniform3fv((char *) "lightPos", 1, value_ptr(lightPos));

        prgRender.Uniform3fv((char *) "bgColor", 1, value_ptr(g_BackgroundColor));

        if (g_Mode == 0)
            mouseXPos = 0;
        else if (g_Mode == 1)
            mouseXPos = 100000;

        prgRender.Uniform1f((char const *) "mouseXPos", mouseXPos);
        prgRender.Uniform1f((char const *) "mouseYPos", mouseYPos);

        // display widget
        scene->draw(&prgRender, 0);

        if (g_ShowTF) {
            // update TF
            if (g_ClearTF) {
                g_ClearTF = 0;
                memset(pCurTF, 0, tfTexHeight * tfTexWidth * 4);
            }
            tTF->bind();
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, tfTexWidth, tfTexHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE,
                         (void *) pCurTF);
            glGenerateMipmap(GL_TEXTURE_2D);

            prgShowTF.bind();
            glDisable(GL_DEPTH_TEST);
            glDisable(GL_CULL_FACE);
            BINDOGLTEX(prgShowTF, "tHistogram", tHistogram, GL_TEXTURE0);
            BINDOGLTEX(prgShowTF, "tTF", tTF, GL_TEXTURE1);
            prgShowTF.Uniform4fv((char const *) "screenWH", 1, value_ptr(vec4(width, height, 0.0f, 0.0f)));
            prgShowTF.Uniform4fv((char const *) "widgetWHPos", 1,
                                 value_ptr(vec4(widgetWidth, widgetHeight, widgetPosX, widgetPosY)));
            wrap.draw();
        }

        setExposureGamma(g_Exposure, g_Gamma);
    }
};

// no need to modify anything below this line

CRender *pRenderClass;

void initialize() {
    pRenderClass = new CRender();
}
