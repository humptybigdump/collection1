#include <application.h>


/* error reporting function */
void error_handler(void* userPtr, const RTCError code, const char* str = nullptr) {
    if (code == RTC_ERROR_NONE)
        return;

    printf("Embree: ");
    switch (code) {
        case RTC_ERROR_UNKNOWN: printf("RTC_ERROR_UNKNOWN");
            break;
        case RTC_ERROR_INVALID_ARGUMENT: printf("RTC_ERROR_INVALID_ARGUMENT");
            break;
        case RTC_ERROR_INVALID_OPERATION: printf("RTC_ERROR_INVALID_OPERATION");
            break;
        case RTC_ERROR_OUT_OF_MEMORY: printf("RTC_ERROR_OUT_OF_MEMORY");
            break;
        case RTC_ERROR_UNSUPPORTED_CPU: printf("RTC_ERROR_UNSUPPORTED_CPU");
            break;
        case RTC_ERROR_CANCELLED: printf("RTC_ERROR_CANCELLED");
            break;
        default: printf("invalid error code");
            break;
    }
    if (str) {
        printf(" (");
        while (*str) putchar(*str++);
        printf(")\n");
    }
    exit(1);
}

void errorFunc(int error, const char* description) {
    throw std::runtime_error(std::string("Error: ") + description);
}

Application::Application(int argc, char** argv, const std::string &name) {
    time0 = getSeconds();

    /* parse command line options */
    // parseCommandLine(argc, argv);

    /* callback */
    // postParseCommandLine();

    /* create embree device */
    g_device = rtcNewDevice("");
    error_handler(nullptr, rtcGetDeviceError(g_device));

    /* set error handler */
    rtcSetDeviceErrorFunction(g_device, error_handler, nullptr);

    glfwSetErrorCallback(errorFunc);
    glfwInit();
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);

    window = glfwCreateWindow(width, height, name.c_str(), nullptr, nullptr);
    if (window == nullptr) {
        throw std::runtime_error("Window couldn't be created");
    }
    resize(width, height);

    glfwMakeContextCurrent(window);
    glfwSwapInterval(0);
    glfwSetWindowUserPointer(window, this);
    glfwSetInputMode(window, GLFW_CURSOR, GLFW_CURSOR_NORMAL);
    setCallbackFunctions();

    ImGui::CreateContext();

    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init();

    // Setup style
    ImGui::StyleColorsDark();

    if (!gladLoadGLLoader(reinterpret_cast<GLADloadproc>(glfwGetProcAddress))) {
        throw std::runtime_error("Failed to initialize GLAD");
    }

    initShader();
    initOpenGL();
}

void Application::initShader() {
    const char* vShaderCode = "#version 430 core\n"
            "layout (location = 0) in vec2 aPos;\n"
            "layout (location = 1) in vec2 aTexCoord;\n"
            "out vec2 TexCoord;\n"
            "void main() {\n"
            "   gl_Position = vec4(aPos.x, aPos.y, 0.0, 1.0);\n"
            "   TexCoord = aTexCoord;\n"
            "}\0";
    const char* fShaderCode = "#version 430 core\n"
            "in vec2 TexCoord;\n"
            "out vec4 FragColor;\n"
            "uniform sampler2D textureSampler;\n"
            "void main() {\n"
            "   FragColor = vec4(texture(textureSampler, TexCoord).rgb,1);\n"
            "}\0";

    unsigned int vertex, fragment;
    int success;
    char infoLog[512];
    // vertex Shader
    vertex = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vertex, 1, &vShaderCode, nullptr);
    glCompileShader(vertex);
    glGetShaderiv(vertex, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vertex, 512, nullptr, infoLog);
        std::cout << "ERROR::SHADER::VERTEX::COMPILATION_FAILED\n" << infoLog << std::endl;
    }
    // fragment shader
    fragment = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fragment, 1, &fShaderCode, nullptr);
    glCompileShader(fragment);
    glGetShaderiv(fragment, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(fragment, 512, nullptr, infoLog);
        std::cout << "ERROR::SHADER::FRAGMENT::COMPILATION_FAILED\n" << infoLog << std::endl;
    }

    shaderID = glCreateProgram();
    glAttachShader(shaderID, vertex);
    glAttachShader(shaderID, fragment);
    glLinkProgram(shaderID);
    glGetProgramiv(shaderID, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(shaderID, 512, nullptr, infoLog);
        std::cout << "ERROR::SHADER::PROGRAM::LINKING_FAILED\n" << infoLog << std::endl;
    }

    glDeleteShader(vertex);
    glDeleteShader(fragment);
}

void Application::initOpenGL() {
    glDisable(GL_DEPTH_TEST);
    glClearColor(0.0, 0.0, 0.0, 1.0);

    // Vertex data for a full-screen quad
    float vertices[] = {
        // Positions   // Texture Coordinates
        -1.0f, 1.0f, 0.0f, 0.0f,
        -1.0f, -1.0f, 0.0f, 1.0f,
        1.0f, 1.0f, 1.0f, 0.0f,
        1.0f, -1.0f, 1.0f, 1.0f,
    };

    // Vertex Buffer Object (VBO) and Vertex Array Object (VAO) setup
    glGenVertexArrays(1, &VAO);
    glGenBuffers(1, &VBO);

    glBindVertexArray(VAO);

    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // Position attribute
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), nullptr);
    glEnableVertexAttribArray(0);

    // Texture coordinate attribute
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 4 * sizeof(float), reinterpret_cast<void *>(2 * sizeof(float)));
    glEnableVertexAttribArray(1);

    glGenTextures(1, &texture_id);
}

void Application::run() {
    std::cout << "start application" << std::endl;
    initScene();

    renderInteractive();
}

void Application::deviceRender(const ISPCCamera& camera) {
    /* create scene */
    if (data.g_scene == nullptr) {
        data.g_scene = convertScene(data.scene);
        rtcCommitScene(data.g_scene);
    }

    /* create accumulator */
    if (data.film.width != width || data.film.height != height) {
        data.film.init(width, height);
    }

    /* reset accumulator */
    bool camera_changed = !g_accumulate;

    camera_changed |= ne(g_accu_vx, camera.xfm.l.vx);
    g_accu_vx = camera.xfm.l.vx;
    camera_changed |= ne(g_accu_vy, camera.xfm.l.vy);
    g_accu_vy = camera.xfm.l.vy;
    camera_changed |= ne(g_accu_vz, camera.xfm.l.vz);
    g_accu_vz = camera.xfm.l.vz;
    camera_changed |= ne(g_accu_p, camera.xfm.p);
    g_accu_p = camera.xfm.p;

    if (camera_changed) {
        resetRender();
    } else
        data.accu_count++;

    data.frame_count++;
}


void Application::renderInteractive() {
    while (!glfwWindowShouldClose(window)) {
        glfwPollEvents();

        displayFunc();
    }

    // Cleanup
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();
    ImGui::DestroyContext();

    glfwDestroyWindow(window);
    glfwTerminate();
}

void Application::displayFunc() {
    double t0 = getSeconds();
    const float time = render_time;

    /* update camera */
    camera.move(moveDelta.x * speed, moveDelta.y * speed, moveDelta.z * speed);

    ISPCCamera ispccamera = camera.getISPCCamera(width, height);

    /* render image using ISPC */
    initRayStats();
    render((int *) pixels, width, height, time, ispccamera);
    data.film.writeToFramebuffer(pixels);
    
    double dt0 = getSeconds() - t0;
    if (ispccamera.render_time != 0.0) dt0 = ispccamera.render_time;
    avg_render_time.add(dt0);
    double mrayps = double(getNumRays()) / (1000000.0 * dt0);
    avg_mrayps.add(mrayps);

    // Start the Dear ImGui frame
    ImGui_ImplOpenGL3_NewFrame();
    ImGui_ImplGlfw_NewFrame();
    ImGui::NewFrame();

    ImGuiWindowFlags window_flags = 0;
    window_flags |= ImGuiWindowFlags_NoTitleBar;
    //window_flags |= ImGuiWindowFlags_NoScrollbar;
    //window_flags |= ImGuiWindowFlags_MenuBar;
    //window_flags |= ImGuiWindowFlags_NoMove;
    //window_flags |= ImGuiWindowFlags_NoResize;
    //window_flags |= ImGuiWindowFlags_NoCollapse;
    //window_flags |= ImGuiWindowFlags_NoNav;

    ImGui::SetNextWindowBgAlpha(0.3f);
    ImGui::Begin("Embree", nullptr, window_flags);
    drawGUI();

    ImGui::Checkbox("Accumulate", &g_accumulate);
    ImGui::InputInt("SPP", &data.spp);

    if (ImGui::Button("Reset")) {
        resetRender();
    };

    double render_dt = avg_render_time.get();
    double render_fps = render_dt != 0.0 ? 1.0f / render_dt : 0.0;
    ImGui::Text("Render: %3.2f fps", render_fps);

    double total_dt = avg_frame_time.get();
    double total_fps = total_dt != 0.0 ? 1.0f / total_dt : 0.0;
    ImGui::Text("Total: %3.2f fps", total_fps);


    ImGui::Text("%3.2f Mray/s", avg_mrayps.get());
    ImGui::End();

    ImGui::Render();

    renderOpenGl();

    ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

    glfwSwapBuffers(window);

#ifdef __APPLE__
    // work around glfw issue #1334
    // https://github.com/glfw/glfw/issues/1334
    static bool macMoved = false;

    if (!macMoved) {
      int x, y;
      glfwGetWindowPos(window, &x, &y);
      glfwSetWindowPos(window, ++x, y);
      macMoved = true;
    }
#endif

    double dt1 = getSeconds() - t0;
    avg_frame_time.add(dt1);
}

void Application::render(int* pixels, int width, int height, float time, const ISPCCamera &camera) {
    deviceRender(camera);

    const int numTilesX = (width + TILE_SIZE_X - 1) / TILE_SIZE_X;
    const int numTilesY = (height + TILE_SIZE_Y - 1) / TILE_SIZE_Y;
    parallel_for(size_t(0), size_t(numTilesX * numTilesY), [&](const range<size_t> &range) {
        const int threadIndex = (int) TaskScheduler::threadIndex();
        for (size_t i = range.begin(); i < range.end(); i++)
            renderTile((int) i, threadIndex, pixels, width, height, time, camera, numTilesX, numTilesY);
    });
}

/* renders a single screen tile */
void Application::renderTile(int taskIndex, int threadIndex, int* pixels, const unsigned int width,
                             const unsigned int height, const float time, const ISPCCamera &camera, const int numTilesX,
                             const int numTilesY) {
    const unsigned int tileY = taskIndex / numTilesX;
    const unsigned int tileX = taskIndex - tileY * numTilesX;
    const unsigned int x0 = tileX * TILE_SIZE_X;
    const unsigned int x1 = min(x0 + TILE_SIZE_X, width);
    const unsigned int y0 = tileY * TILE_SIZE_Y;
    const unsigned int y1 = min(y0 + TILE_SIZE_Y, height);

    for (unsigned int y = y0; y < y1; y++)
        for(unsigned int x = x0; x < x1; x++) {
            RandomSamplerWrapper sampler;
            Vec3fa L = Vec3fa(0.0f);

            for (int i=0; i<data.spp; i++)
            {
				sampler.init(x, y, (data.frame_count) * data.spp + i);

				/* calculate pixel color */
				float fx = x + sampler.get1D();
				float fy = y + sampler.get1D();
                L = L + renderPixel(fx,fy,camera,g_stats[threadIndex],sampler);
            }
            L = L/(float)data.spp;

            /* write color to framebuffer */
            data.film.addSplat(x, y, L);
        }
}

void Application::renderOpenGl() {
    glBindTexture(GL_TEXTURE_2D, texture_id);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA32F, width, height, 0, GL_RGBA,
                 GL_UNSIGNED_BYTE, pixels);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUseProgram(shaderID);

    glBindTexture(GL_TEXTURE_2D, texture_id);

    glBindVertexArray(VAO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    glBindTexture(GL_TEXTURE_2D, 0);
}

void Application::setCallbackFunctions() {
    glfwSetFramebufferSizeCallback(window, [](GLFWwindow* w, const int new_width, const int new_height) {
        static_cast<Application *>(glfwGetWindowUserPointer(w))->framebufferSizeCallback(w, new_width, new_height);
    });
    glfwSetCursorPosCallback(window, [](GLFWwindow* w, const double xpos, const double ypos) {
        static_cast<Application *>(glfwGetWindowUserPointer(w))->mouseCursorCallback(w, xpos, ypos);
    });
    glfwSetMouseButtonCallback(window, [](GLFWwindow* w, const int button, const int action, const int mods) {
        static_cast<Application *>(glfwGetWindowUserPointer(w))->mouseButtonCallback(w, button, action, mods);
    });
    glfwSetKeyCallback(window, [](GLFWwindow* w, int key, int scancode, int action, int mods) {
        static_cast<Application *>(glfwGetWindowUserPointer(w))->keyCallback(w, key, scancode, action, mods);
    });
    glfwSetScrollCallback(window, [](GLFWwindow* w, double xoffset, double yoffset) {
        static_cast<Application *>(glfwGetWindowUserPointer(w))->scrollCallback(w, xoffset, yoffset);
    });
}

void Application::resize(int width, int height) {
    if (width == this->width && height == this->height && pixels)
        return;

    this->width = width;
    this->height = height;

    if (pixels) alignedUSMFree(pixels);
    pixels = (unsigned int *) alignedUSMMalloc(width * height * sizeof(unsigned int), 64,
                                               EMBREE_USM_SHARED_DEVICE_READ_WRITE);
}

void Application::framebufferSizeCallback(GLFWwindow*, int width, int height) {
    resize(width, height);
    glViewport(0, 0, width, height);
    this->width = width;
    this->height = height;
}

void Application::mouseCursorCallback(GLFWwindow*, double x, double y) {
    if (ImGui::GetIO().WantCaptureMouse) return;

    float dClickX = float(clickX - x), dClickY = float(clickY - y);
    clickX = x;
    clickY = y;

    switch (mouseMode) {
        case 1:
            camera.rotateOrbit(-0.005f * dClickX, 0.005f * dClickY);
            break;
        case 2:
            break;
        case 3:
            camera.dolly(-dClickY);
            break;
        case 4:
            camera.rotate(-0.005f * dClickX, 0.005f * dClickY);
            break;
        default:
            break;
    }
}

void Application::mouseButtonCallback(GLFWwindow*, int button, int action, int mods) {
    if (ImGui::GetIO().WantCaptureMouse) return;

    double x, y;
    glfwGetCursorPos(window, &x, &y);

    if (action == GLFW_RELEASE) {
        mouseMode = 0;
    } else if (action == GLFW_PRESS) {
        if (button == GLFW_MOUSE_BUTTON_MIDDLE) {
            printf("pixel pos (%d, %d)\n", (int) x, (int) y);
        } else {
            clickX = x;
            clickY = y;
            if (button == GLFW_MOUSE_BUTTON_LEFT && mods == GLFW_MOD_SHIFT) mouseMode = 4;
            else if (button == GLFW_MOUSE_BUTTON_LEFT && mods == GLFW_MOD_CONTROL) mouseMode = 3;
            else if (button == GLFW_MOUSE_BUTTON_LEFT) mouseMode = 1;
        }
    }
}

void Application::keyCallback(GLFWwindow*, int key, int scancode, int action, int mods) {
    if (ImGui::GetIO().WantCaptureKeyboard) return;

    if (action == GLFW_PRESS) {
        switch (key) {
            case GLFW_KEY_LEFT:
                camera.rotate(-0.02f, 0.0f);
                break;
            case GLFW_KEY_RIGHT:
                camera.rotate(+0.02f, 0.0f);
                break;
            case GLFW_KEY_UP:
                camera.move(0.0f, 0.0f, +speed);
                break;
            case GLFW_KEY_DOWN:
                camera.move(0.0f, 0.0f, -speed);
                break;
            case GLFW_KEY_PAGE_UP:
                speed *= 1.2f;
                break;
            case GLFW_KEY_PAGE_DOWN:
                speed /= 1.2f;
                break;

            case GLFW_KEY_W:
                moveDelta.z = +1.0f;
                break;
            case GLFW_KEY_S:
                moveDelta.z = -1.0f;
                break;
            case GLFW_KEY_A:
                moveDelta.x = -1.0f;
                break;
            case GLFW_KEY_D:
                moveDelta.x = +1.0f;
                break;

            case GLFW_KEY_C: std::cout << camera.str() << std::endl;
                break;

            case GLFW_KEY_SPACE: {
                // TODO Store image
                // Ref<Image> image = new Image4uc(width, height, (Col4uc *) pixels, true, "", true);
                // storeImage(image, "screenshot.tga");
                break;
            }

            case GLFW_KEY_ESCAPE:
            case GLFW_KEY_Q:
                glfwSetWindowShouldClose(window, 1);
                break;
            default:
                break;
        }
    } else if (action == GLFW_RELEASE) {
        switch (key) {
            case GLFW_KEY_W:
            case GLFW_KEY_S:
                moveDelta.z = 0.0f;
                break;
            case GLFW_KEY_A:
            case GLFW_KEY_D:
                moveDelta.x = 0.0f;
                break;
            default:
                break;
        }
    }
}

void Application::scrollCallback(GLFWwindow*, double xoffset, double yoffset) {
    if (ImGui::GetIO().WantCaptureMouse) return;
    camera.dolly(yoffset * 10.f);
}

void Application::initRayStats() {
    if (!g_stats)
        g_stats = (RayStats *) embree::alignedMalloc(embree::TaskScheduler::threadCount() * sizeof(RayStats), 64);

    for (size_t i = 0; i < TaskScheduler::threadCount(); i++)
        g_stats[i].numRays = 0;
}

int64_t Application::getNumRays() {
    int64_t numRays = 0;
    for (size_t i = 0; i < TaskScheduler::threadCount(); i++)
        numRays += g_stats[i].numRays;
    return numRays;
}
