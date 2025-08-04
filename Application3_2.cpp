#include "Application3.h"

void Application3::initScene() {
    Data_Constructor(&data, 1, 8);

    /* select scene here */
    //standardScene();
    causticScene();
}

void Application3::standardScene() {
    FileName file = workingDir + FileName("Framework/scenes/cornell_box.obj");

    /* set default camera */
    camera.from = Vec3fa(278, 273, -800);
    camera.to = Vec3fa(278, 273, 0);

    Ref<SceneGraph::GroupNode> sceneGraph = loadOBJ(file, false).cast<SceneGraph::GroupNode>();

    auto light = new SceneGraph::QuadLightMesh(Vec3fa(343.0, 548.0, 227.0), Vec3fa(213.0, 548.0, 332.0),
                                               Vec3fa(343.0, 548.0, 332.0),
                                               Vec3fa(213.0, 548.0, 227.0), Vec3fa(25, 25, 25));
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

void Application3::causticScene() {
	FileName file = workingDir + FileName("Framework/scenes/caustics/ring.obj");

	/* set default camera */
	camera.from = Vec3fa(1, 2, 1);
	camera.to = Vec3fa(0, 0, 0);
	camera.fov = 60;

	Ref<SceneGraph::GroupNode> sceneGraph = loadOBJ(file, false).cast<SceneGraph::GroupNode>();

	auto light = new SceneGraph::QuadLightMesh(Vec3fa(0.1, 1.0, 2.0), Vec3fa(-0.1, 1.2, 2.0),
		Vec3fa(-0.1, 1.0, 2.0), Vec3fa(0.1, 1.2, 2.0),
		Vec3fa(50, 50, 50));

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


/*
    IMPORTANT: use your own path tracing implementation from the 1st assignment!! 
    the only change that we made was introduction of the RandomSamplerWrapper. It wrappes the sampling routines, so you could introduce a new sampler for Metropolis Light Transport and by overwriting RandomSamplerWrapper methods: get1D(), get2D()...
	also the drawGUI() function now invokes ApplicationIntegrator::drawGUI();
*/

/* task that renders a single screen tile */
Vec3fa Application3::renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSamplerWrapper& sampler) {
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
            Material__sample(material_array, matId, brdf, Lw, wo, sample, wi1, sampler.get2D());

            int id = (int)(sampler.get1D()* data.scene->lights.size());
            if (id == data.scene->lights.size())
                id = data.scene->lights.size() - 1;
            const Light* l = data.scene->lights[id];

            Light_SampleRes ls = Lights_sample(l, sample, sampler.get2D());

            Vec3fa diffuse = Material__eval(material_array, matId, brdf, wo, sample, ls.dir);

            /* initialize shadow ray */
            Ray shadow(sample.P, ls.dir, 0.001f, ls.dist-0.001f, 0.0f);

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
