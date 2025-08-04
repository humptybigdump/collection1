#include "Application1.h"

void Application1::initScene() {
    Data_Constructor(&data, 1, 8);

    /* select scene here */
    standardScene();
    // veachScene();
}

void Application1::standardScene() {
    FileName file = workingDir + FileName("Framework/scenes/cornell_box.obj");

    /* set default camera */
    camera.from = Vec3fa(278, 273, -800);
    camera.to = Vec3fa(278, 273, 0);

    Ref<SceneGraph::GroupNode> sceneGraph = loadOBJ(file, false).cast<SceneGraph::GroupNode>();

    auto light = new SceneGraph::QuadLightMesh(Vec3fa(343.0, 548.0, 227.0), Vec3fa(213.0, 548.0, 332.0),
                                               Vec3fa(343.0, 548.0, 332.0),
                                               Vec3fa(213.0, 548.0, 227.0), Vec3fa(100, 100, 100));
    sceneGraph->add(light);

    Ref<SceneGraph::GroupNode> flattened_scene = SceneGraph::flatten(sceneGraph, SceneGraph::INSTANCING_NONE);
    Scene* scene = new Scene;
    scene->add(flattened_scene);
    sceneGraph = nullptr;
    flattened_scene = nullptr;

    auto renderScene = new RenderScene(g_device, scene);
    g_render_scene = renderScene;
    data.scene = renderScene;
    scene = nullptr;
}

void Application1::veachScene() {
    FileName file = workingDir + FileName("Framework/scenes/veach.obj");

    /* set default camera */
    camera.from = Vec3fa(1050, 185, 275);
    camera.to = Vec3fa(255, 273, 271);
    camera.fov = 60;

    Ref<SceneGraph::GroupNode> sceneGraph = loadOBJ(file, false).cast<SceneGraph::GroupNode>();

    auto light = new SceneGraph::QuadLightMesh(Vec3fa(549.6, 0.0, 559.2), Vec3fa(0.0, 548.8, 559.2),
                                               Vec3fa(0.0, 0.0, 559.2), Vec3fa(556.0, 548.8, 559.2),
                                               Vec3fa(10, 10, 10));
    sceneGraph->add(light);


    Ref<SceneGraph::GroupNode> flattened_scene = SceneGraph::flatten(sceneGraph, SceneGraph::INSTANCING_NONE);
    Scene* scene = new Scene;
    scene->add(flattened_scene);
    sceneGraph = nullptr;
    flattened_scene = nullptr;

    auto renderScene = new RenderScene(g_device, scene);
    g_render_scene = renderScene;
    data.scene = renderScene;
    scene = nullptr;
}

/* task that renders a single screen tile */
Vec3fa Application1::renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSampler& sampler) {
    /* radiance accumulator and weight */
    Vec3fa L = Vec3fa(0.0f);
    Vec3fa Lw = Vec3fa(1.0f);

    /* initialize ray */
    Ray ray(Vec3fa(camera.xfm.p), Vec3fa(normalize(x * camera.xfm.l.vx + y * camera.xfm.l.vy + camera.xfm.l.vz)), 0.0f,
            inf);

    /* intersect ray with scene */
    RTCIntersectArguments iargs;
    rtcInitIntersectArguments(&iargs);
    iargs.feature_mask = RTC_FEATURE_FLAG_TRIANGLE;
    rtcIntersect1(data.g_scene, RTCRayHit_(ray), &iargs);
    RayStats_addRay(stats);

    const Vec3fa wo = neg(ray.dir);

    /* shade pixels */
    if (ray.geomID != RTC_INVALID_GEOMETRY_ID) {
        Vec3fa Ns = normalize(ray.Ng);
        Sample sample;
        sample.P = ray.org + ray.tfar * ray.dir;
        sample.Ng = ray.Ng;
        sample.Ns = Ns;
        unsigned matId = data.scene->geometries[ray.geomID]->materialID;
        unsigned lightID = data.scene->geometries[ray.geomID]->lightID;

        if (lightID != unsigned(-1)) {
            const Light* l = data.scene->lights[lightID];
            Light_EvalRes evalRes = Lights_eval(l, sample, -wo);

            L += evalRes.value;
        } else {
            sample.Ng = face_forward(ray.dir, normalize(sample.Ng));
            sample.Ns = face_forward(ray.dir, normalize(sample.Ns));

            /* calculate BRDF */
            BRDF brdf;
            std::vector<Material *> material_array = data.scene->materials;
            Material__preprocess(material_array, matId, brdf, wo, sample);

            /* sample BRDF at hit point */
            Sample3f wi1;
            Material__sample(material_array, matId, brdf, Lw, wo, sample, wi1, RandomSampler_get2D(sampler));

            int id = (int)(RandomSampler_get1D(sampler) * data.scene->lights.size());
            if (id == data.scene->lights.size())
                id = data.scene->lights.size() - 1;
            const Light* l = data.scene->lights[id];

            Light_SampleRes ls = Lights_sample(l, sample, RandomSampler_get2D(sampler));

            Vec3fa diffuse = Material__eval(material_array, matId, brdf, wo, sample, ls.dir);

            /* initialize shadow ray */
            Ray shadow(sample.P, ls.dir, 0.001f, ls.dist, 0.0f);

            /* trace shadow ray */
            RTCOccludedArguments sargs;
            rtcInitOccludedArguments(&sargs);
            sargs.feature_mask = RTC_FEATURE_FLAG_TRIANGLE;
            rtcOccluded1(data.g_scene, RTCRay_(shadow), &sargs);
            RayStats_addShadowRay(stats);

            /* add light contribution if not occluded */
            if (shadow.tfar >= 0.0f) {
                L += diffuse * ls.weight;
            }
        }
    }

    return L;
}
