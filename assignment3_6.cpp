#include "AntTweakBar.h"
#if 1

////////////////////////////////////////////////////////////
//                                                        //
//  Visual Computing & FERT Framework                     //
//                                                        //
//  This code is based on GLEW and the www.gpgpu.org      //
//  frame-buffer-object framework.                        //
//                                                        //
////////////////////////////////////////////////////////////

#include <iterator>

#include "stdafx.h"

#include "shader/shared.h.glsl"
#include "opengl_debug.h"

extern "C"
{
	_declspec(dllexport) DWORD NvOptimusEnablement = 1;
	_declspec(dllexport) int AmdPowerXpressRequestHighPerformance = 1;
}

char applicationTitle[128] = "Assignment3";

const char path2Demo[] = "Assignments/Assignment3/";

using namespace glm;

#ifdef USE_TWEAK_BAR
TwBar *bar = NULL; // Pointer to a tweak bar

bool clearBuffer = true;
int budget = 32;

static void CheckGLError()
{
	int err = 0;
	char msg[256];
	while ((err = glGetError()) != 0)
	{
		sprintf(msg, "GL_ERROR=0x%x\n", err);
#ifdef ANT_WINDOWS
		OutputDebugString(msg);
#endif
		fprintf(stderr, msg);
	}
}

std::string makeDefineString(const std::map<std::string, std::string> &parameters)
{
	std::vector<std::string> defines;
	for (auto it = parameters.begin(); it != parameters.end(); ++it)
	{
		std::string currentDefine = "#define " + it->first + " " + it->second;
		defines.push_back(currentDefine);
	}
	std::stringstream result;
	std::copy(defines.begin(), defines.end(), std::ostream_iterator<std::string>(result, "\n"));
	return result.str();
}

void initializeTweakBar()
{
	if (bar != NULL)
		TwDeleteBar(bar);
	else
		TwTerminate();
	nTweakBarVariables = 0;

	// Create a tweak bar
	TwDefine("GLOBAL fontscaling=2");
	TwInit(TW_OPENGL, NULL);
	TwDefine("GLOBAL fontsize=3");

	bar = TwNewBar("Tiny Renderer");

	TwDefine("'Tiny Renderer' position='8 30'");
	TwDefine("'Tiny Renderer' size='600 400'");
	TwDefine("'Tiny Renderer' text=light");

	TwAddVarRW(bar, "budget", TW_TYPE_INT32, &budget, " min=1 label='Budget'");
	TwAddButton(bar, "clear", [](void *data)
				{ clearBuffer = true; }, NULL, " label='Clear Buffer'");
}
#endif

class CRender : public CRenderBase
{
protected:
	Scene *scene;  // scene for loading .obj and computing a BVH
	Camera camera; // camera (acts as trackball by default)
	EnvMap *envmap;
	GLSLProgram prgRender; // GLSL programs, each one can keep a vertex and a fragment shader
    IMWrap* wrap; // wrapper for OpenGL immediate calls

	GLSLProgram prgPostProc; // GLSL programs, each one can keep a vertex and a fragment shader
	GLSLProgram prgDepth; // GLSL programs, each one can keep a vertex and a fragment shader

    OGLTexture *tGPosition, *tGNormal, *tGColor;

    FramebufferObject pDeferredFBO;
    Renderbuffer pDeferredRenderBuffer;

	
	std::unique_ptr<OGlBuffer<vMFlobe>> bVMFBuffer;

public:
	CRender()
	{
		initializeOpenGLDebugCallback();
		glfwGetWindowSize(glfwWindow, &width, &height);

		enableGLDebugOutput = false;
		offScreenRenderTarget = true; // required for multi sampling, stereo, accumulation
		useMultisampling = false;
		stereoRendering = false;
		useAccumulationBuffer = false; // call clearAccumulationBuffer(); in sceneFrameRender() to clear the buffer
		// accumulationEWA		  = 0.04f;		// if this value is set (to != 1.0f which is default) then accumulation buffer images will be accumulated using exponentially weighted averaging

		// called here as the initialization depends on some flags we can set in CRender
		CRenderBase::CRenderBaseInit();

		// load and/or create shaders, textures, and models
		loadShaders(true);
		createTextures();
		loadModels();

		// call it here so that these textures show up at the end in the texture manager
		CRenderBase::createTextures();

		bVMFBuffer = std::make_unique<OGlBuffer<vMFlobe>>(GL_SHADER_STORAGE_BUFFER, width * height);
	}

	~CRender()
	{
		if (scene)
			delete scene;
	}

	//
	// load 3d models
	//
	void loadModels()
	{
		scene = new Scene(texMan);
		envmap = new EnvMap();
		const char *attribs[3] = {"in_position", "in_normal", "in_texcoord"};

		envmap->initialize(texMan, "data/mud_road_puresky_4k.hdr");

		// scene->loadOBJ( SCENE_SMOOTH | /*SCENE_TEXTURE | */SCENE_COLOR, prgRender.getProgramObject(), 3, (const char **)attribs, "whitted_rt.obj", "./data/", true, &rotate( mat4( 1.0f ), radians( -0.0f ), vec3( 1.0f, 0.0f, 0.0f ) ) );
		//  scene->loadOBJ( SCENE_SMOOTH | SCENE_COLOR, prgRender.getProgramObject(), 3, (const char **)attribs, "CornellBox_Original.obj", "./data/", true );
		scene->loadOBJ(SCENE_SMOOTH | SCENE_COLOR, prgRender.getProgramObject(), 3, (const char **)attribs, "cbox.obj", "./data/", true);
		// scene->loadOBJ( SCENE_SMOOTH | SCENE_COLOR, prgRender.getProgramObject(), 3, (const char **)attribs, "dragon_with_plane.obj", "./data/", true );
		scene->buildBVH(0);
	}

	//
	// load vertex and fragment shaders
	//
	void loadShaders(bool firstTime = false)
	{
		if (!firstTime)
			CRenderBase::loadShaders(firstTime);

		// load and setup a shader
		if (!prgRender.loadVertexShader(tmpStrCat(path2Demo, "shader/perpixel_lighting.vp.glsl")) ||
			!prgRender.loadFragmentShader(tmpStrCat(path2Demo, "shader/perpixel_lighting.fp.glsl")))
		{
			if (firstTime)
				exit(1);
		}

		prgRender.link();
		glBindFragDataLocation(prgRender.getProgramObject(), 0, "out_color");
        glBindFragDataLocation(prgRender.getProgramObject(), 1, "out_pos");
        glBindFragDataLocation(prgRender.getProgramObject(), 2, "out_normal");

		CheckGLError();

#ifdef USE_TWEAK_BAR
		if (firstTime)
		{
			initializeTweakBar();

			// parse the shader for UI-variables, add them to AntTweakBar in section 'auto-gen variables'
			parseShaderTweakBar(bar, &prgRender, prgRender.getFragmentShaderSrc(), "auto-gen variables");
		}
#endif

		// load and setup a shader
		if (!prgDepth.loadVertexShader(tmpStrCat(path2Demo, "shader/perpixel_lighting.vp.glsl")) || 
			!prgDepth.loadFragmentShader(tmpStrCat(path2Demo, "shader/noop.fp.glsl")))
		{
			if (firstTime)
				exit(1);
		}

		prgDepth.link();

		CheckGLError();

		// this shows how to load a custom post processing shader and parsing its source for UI-variables
		if (!prgPostProc.loadVertexShader(tmpStrCat(path2Demo, "shader/postprocess.vp.glsl")) ||
			!prgPostProc.loadFragmentShader(tmpStrCat(path2Demo, "shader/postprocess.fp.glsl")))
		{
			if (firstTime)
				exit(1);
		}
		prgPostProc.link();
		glBindFragDataLocation( prgPostProc.getProgramObject(), 0, "result" );
		
		wrap = new IMWrap();
		wrap->bindShader( prgPostProc.getProgramObject(), 2, "in_position", "in_texcoord" );
		wrap->Begin( GL_TRIANGLES );
		wrap->Attrib2f( 1, 0, 0 );
		wrap->Vertex3f( -1, -1, -0.5f );
		wrap->Attrib2f( 1, 1, 0 );
		wrap->Vertex3f( 1, -1, -0.5f );
		wrap->Attrib2f( 1, 1, 1 );
		wrap->Vertex3f( 1, 1, -0.5f );

		wrap->Attrib2f( 1, 0, 0 );
		wrap->Vertex3f( -1, -1, -0.5f );
		wrap->Attrib2f( 1, 1, 1 );
		wrap->Vertex3f( 1, 1, -0.5f );
		wrap->Attrib2f( 1, 0, 1 );
		wrap->Vertex3f( -1, 1, -0.5f );
		wrap->End();
		
		CheckGLError();

#ifdef USE_TWEAK_BAR
		if (firstTime)
		{
			parseShaderTweakBar( bar, &prgPostProc, prgPostProc.getFragmentShaderSrc(), "Post Process" );
		}
#endif

	}

	//
	// create textures and render targets
	//
	void createTextures()
	{
        int w, h;
        glfwGetWindowSize(glfwWindow, &w, &h);

        // bind the frame buffer object
        pDeferredFBO.Bind();

        // create and attach textures to framebuffer color buffer
        texMan->CreateTexture(&tGColor, w, h, GL_RGBA16F_ARB, "color");
        texMan->CreateTexture(&tGPosition, w, h, GL_RGBA16F_ARB, "position");
        texMan->CreateTexture(&tGNormal, w, h, GL_RGBA16F_ARB, "normals");
        pDeferredFBO.AttachTexture(GL_TEXTURE_2D, tGColor->getID(), GL_COLOR_ATTACHMENT0);
        pDeferredFBO.AttachTexture(GL_TEXTURE_2D, tGPosition->getID(), GL_COLOR_ATTACHMENT1);
        pDeferredFBO.AttachTexture(GL_TEXTURE_2D, tGNormal->getID(), GL_COLOR_ATTACHMENT2);

        // initialize and attach depth renderbuffer
        pDeferredRenderBuffer.Set(GL_DEPTH24_STENCIL8, w, h);
        pDeferredFBO.AttachRenderBuffer(pDeferredRenderBuffer.GetId(), GL_DEPTH_ATTACHMENT);

        // validate the fbo after attaching textures and render buffers
        pDeferredFBO.IsValid();

        // disable fbo rendering for now
        FramebufferObject::Disable();
	}

	void firstFramePrep()
	{
		scene->uploadBVH2GPU( width, height );
		scene->setBVHShaderUniforms( &prgRender );
		
		bVMFBuffer->bindBase(VMF_OFFSET + 0, GL_SHADER_STORAGE_BUFFER);
		bVMFBuffer->zero();

		loadShaders();
	}

	
    //
    // render scene to G-buffers
    //
    void sceneRenderDepth() {
		// now bind the program and set the parameters
		prgDepth.bind();
        //
        // save current render target and viewport
        //
        GLint camRenderTarget, camViewPort[4];
        glGetIntegerv(GL_DRAW_BUFFER, &camRenderTarget);
        glGetIntegerv(GL_VIEWPORT, camViewPort);

        //
        // setup viewport and OpenGL-states
        //
        int w, h;
        glfwGetWindowSize(glfwWindow, &w, &h);
        glViewport(0, 0, w, h);

        pDeferredFBO.Bind();
		CheckGLError();

		
		// set some render states
		glEnable( GL_DEPTH_TEST );
		CheckGLError();
		glEnable( GL_CULL_FACE );
		CheckGLError();

		// clear screen
		glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
		CheckGLError();
		//glClearColor( 0.3f, 0.3f, 0.3f, 0.2f );
		CheckGLError();
		glClear( GL_DEPTH_BUFFER_BIT );
		CheckGLError();



		CheckGLError();

		// this makro bins the texture object 'tDiffuse' to the shader program 'prgRender'
		// where the sampler is called 'tObjMapKd', and texture unit #0 is used
		// (essentially this is a bind + Uniform1i)
		//BINDOGLTEX( prgRender, "tObjMapKd", tDiffuse,   GL_TEXTURE0 );
		//BINDOGLTEX( prgRender, "tObjMapNs", tNormalMap, GL_TEXTURE1 );

		// compute some matrices and set uniforms
		mat4 matM, matNrml;
		camera.computeMatrices( &trackball, matM, 0 );
		matNrml = transpose( inverse( matM ) );
		
		CheckGLError();

		static int sampleIdx = 0;
		sampleIdx ++;
		
		CheckGLError();
		prgDepth.UniformMatrix4fv( (char const*)"matM",    1, false, value_ptr( matM ) );
		CheckGLError();
		prgDepth.UniformMatrix4fv( (char const*)"matNrml", 1, false, value_ptr( matNrml ) );
		CheckGLError();
		prgDepth.UniformMatrix4fv( (char const*)"matMV",   1, false, value_ptr( camera.matMV ) );
		CheckGLError();
		prgDepth.UniformMatrix4fv( (char const*)"matVP",   1, false, value_ptr( camera.matVP) );
		CheckGLError();
		prgDepth.UniformMatrix4fv( (char const*)"matV",    1, false, value_ptr( camera.matV ) );
		CheckGLError();

		mat4 matMVP = camera.matMVP;
		prgDepth.UniformMatrix4fv( (char *)"matMVP", 1, false, value_ptr( matMVP ) );
		//prgRender.UniformMatrix4fv( (char const*)"matMVP",  1, false, value_ptr( camera.matMVP ) );

		CheckGLError();


		// render objects
		scene->draw( &prgDepth, RENDER_MATERIALS );
		
		CheckGLError();
		//
        // restore viewport and render target
        //
        pDeferredFBO.Disable();
        glViewport(camViewPort[0], camViewPort[1], camViewPort[2], camViewPort[3]);
        GLenum buffersCam[] = {(GLenum) camRenderTarget};
        glDrawBuffers(1, buffersCam);

		CheckGLError();

		glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
		CheckGLError();

	}

	
    //
    // render scene to G-buffers
    //
    void sceneRenderGBuffers(int frame) {
        //
        // save current render target and viewport
        //
        GLint camRenderTarget, camViewPort[4];
        glGetIntegerv(GL_DRAW_BUFFER, &camRenderTarget);
        glGetIntegerv(GL_VIEWPORT, camViewPort);

        //
        // setup viewport and OpenGL-states
        //
        int w, h;
        glfwGetWindowSize(glfwWindow, &w, &h);
        glViewport(0, 0, w, h);

        pDeferredFBO.Bind();
		CheckGLError();

        const GLenum buffers[3] = {GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1, GL_COLOR_ATTACHMENT2};
        glDrawBuffers(3, buffers);

		#ifdef USE_TWEAK_BAR
		setShaderUniformsTweakBar();
		#endif
		CheckGLError();

		// set some render states
		glEnable( GL_DEPTH_TEST );
		CheckGLError();
		glEnable( GL_CULL_FACE );
		CheckGLError();
		
		glDepthFunc(GL_EQUAL); 
		// CheckGLError();
		glDepthMask(GL_FALSE);
		// CheckGLError();

		// clear screen
		glClearColor( 0.3f, 0.3f, 0.3f, 0.2f );
		glClear( GL_COLOR_BUFFER_BIT  );

		// now bind the program and set the parameters
		prgRender.bind();

		envmap->bind(&prgRender);
		CheckGLError();

		// this makro bins the texture object 'tDiffuse' to the shader program 'prgRender'
		// where the sampler is called 'tObjMapKd', and texture unit #0 is used
		// (essentially this is a bind + Uniform1i)
		//BINDOGLTEX( prgRender, "tObjMapKd", tDiffuse,   GL_TEXTURE0 );
		//BINDOGLTEX( prgRender, "tObjMapNs", tNormalMap, GL_TEXTURE1 );

		// compute some matrices and set uniforms
		mat4 matM, matNrml;
		camera.computeMatrices( &trackball, matM, 0 );
		matNrml = transpose( inverse( matM ) );
		
		CheckGLError();
		
		static int sampleIdx = 0;
		sampleIdx ++;
		
		CheckGLError();
		prgRender.UniformMatrix4fv( (char const*)"matM",    1, false, value_ptr( matM ) );
		CheckGLError();
		prgRender.UniformMatrix4fv( (char const*)"matNrml", 1, false, value_ptr( matNrml ) );
		CheckGLError();
		prgRender.UniformMatrix4fv( (char const*)"matMV",   1, false, value_ptr( camera.matMV ) );
		CheckGLError();
		prgRender.UniformMatrix4fv( (char const*)"matVP",   1, false, value_ptr( camera.matVP) );
		CheckGLError();
		prgRender.UniformMatrix4fv( (char const*)"matV",    1, false, value_ptr( camera.matV ) );
		CheckGLError();

		CheckGLError();
		mat4 matMVP = camera.matMVP;
		prgRender.UniformMatrix4fv( (char *)"matMVP", 1, false, value_ptr( matMVP ) );
		//prgRender.UniformMatrix4fv( (char const*)"matMVP",  1, false, value_ptr( camera.matMVP ) );

		CheckGLError();
		prgRender.Uniform3fv( (char const*)"camPos", 1, value_ptr( camera.camPos ) );
		prgRender.Uniform1f( (char const*)"time", (float)frame );
		prgRender.Uniform1i("frameIdx", frame);
		CheckGLError();
		
		prgRender.Uniform1i( (char const*)"width", width );
		CheckGLError();
		prgRender.Uniform1i( (char const*)"height", height );


		CheckGLError();
		// render objects
		scene->draw( &prgRender, RENDER_MATERIALS );
		
		CheckGLError();
        //
        // restore viewport and render target
        //
        pDeferredFBO.Disable();
        glViewport(camViewPort[0], camViewPort[1], camViewPort[2], camViewPort[3]);
        GLenum buffersCam[] = {(GLenum) camRenderTarget};
		glDrawBuffers(1, buffersCam);

		// CheckGLError();
		glDepthMask(GL_TRUE);
		glDepthFunc(GL_LESS);

		CheckGLError();
	}

	
    //
    // render post processing
    //
    void scenePostProc() {
		int w, h;
		glfwGetWindowSize( glfwWindow, &w, &h );

		glDisable( GL_BLEND );
		glEnable( GL_TEXTURE_2D );
		glDisable( GL_DEPTH_TEST );
		glDisable( GL_CULL_FACE );
		
    	// Clear the screen with a specific color
    	glClearColor(0.2f, 0.6f, 0.1f, 1.0f);
    	glClear(GL_COLOR_BUFFER_BIT);

        prgPostProc.bind();
		
        BINDOGLTEX(prgPostProc, "tColor", tGColor, GL_TEXTURE0);
        BINDOGLTEX(prgPostProc, "tPosition", tGPosition, GL_TEXTURE1);
        BINDOGLTEX(prgPostProc, "tNormal", tGNormal, GL_TEXTURE2);
		
		prgPostProc.Uniform1i( (char const*)"width", w );
		prgPostProc.Uniform1i( (char const*)"height", h );

		wrap->draw();

		glBindFramebuffer( GL_DRAW_FRAMEBUFFER, 0 );
	}

	//
	// render a frame of the scene
	//
	void sceneRender()
	{
		
		static int frame = 0;
		if ( frame == 0 )
		{
			firstFramePrep();
		}
		frame ++;
			
		sceneRenderDepth();
		sceneRenderGBuffers(frame);

        if (offScreenRenderTarget)
            CRenderBase::prepareOffScreenRendering();

        scenePostProc();
		
        if (offScreenRenderTarget)
            CRenderBase::finishOffScreenRendering();

        scenePostProcess();

	}

};


// no need to modify anything below this line

CRender *pRenderClass;

void initialize()
{
	pRenderClass = new CRender();
}

#endif
