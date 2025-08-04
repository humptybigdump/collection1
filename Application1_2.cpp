#include "Application1.h"

void Application1::initScene() {
    Data_Constructor(&data, 1, 8);

    /* select scene here */
    standardScene();
    //veachScene();
}

void Application1::standardScene() {
    FileName file = workingDir + FileName("Framework/scenes/cornell_box.obj");

    /* set default camera */
    camera.from = Vec3fa(278, 273, -400);
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

Vec3fa Application1::sampleUniformHemisphere(const Vec2f& s, const Vec3fa& N) {
	float z = s[0];
	float r = embree::sqrt(1 - z * z);
	float phi = 2.f * M_PI * s[1];
	Vec3fa dir = Vec3fa(r * std::cos(phi), r * std::sin(phi), z);
	return frame(N) * dir;
}

/* task that renders a single screen tile */
Vec3fa Application1::renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSamplerWrapper& sampler) {
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

            L += evalRes.value* intensity;
        } else {
            sample.Ng = face_forward(ray.dir, normalize(sample.Ng));
            sample.Ns = face_forward(ray.dir, normalize(sample.Ns));

            /* calculate BRDF */
            BRDF brdf;
            std::vector<Material *> material_array = data.scene->materials;
            Material__preprocess(material_array, matId, brdf, wo, sample);

            /* sample BRDF at hit point */            

            
			float pdf = one_over_two_pi;
			Vec3fa wi = sampleUniformHemisphere(sampler.get2D(), sample.Ns);
            Vec3fa thp = brdf.Kd * one_over_pi * clamp(dot(wi, sample.Ns));
            
             

			Ray indRay(Vec3fa(sample.P), Vec3fa(wi), 0.0001f, inf);
			rtcIntersect1(data.g_scene, RTCRayHit_(indRay), &iargs);
			RayStats_addRay(stats);

            if (indRay.geomID != RTC_INVALID_GEOMETRY_ID) {
                unsigned indMatId = data.scene->geometries[indRay.geomID]->materialID;
                unsigned indLightID = data.scene->geometries[indRay.geomID]->lightID;

                Vec3fa indNs = normalize(indRay.Ng);

                Sample indSample;
                indSample.P = indRay.org + indRay.tfar * indRay.dir;
                indSample.Ng = indRay.Ng;
                indSample.Ns = indNs;

                if (indLightID != unsigned(-1)) {
                    const Light* l = data.scene->lights[indLightID];
                    Light_EvalRes evalRes = Lights_eval(l, indSample, wi);

                    L += thp*evalRes.value/pdf* intensity;
                }
            }

            // here we sample just a random light source. please make it with respect to their emissive profile

            // The data structures and the functions you may want to use for the NEE:
            /*
                data.scene->lights - the scene array with lights
                
                Lights_sample(...) samples a point on the light source (for example, on an emissive area light)


                shadow-querying:
                Ray shadowRay(...)
				RTCOccludedArguments sargs;
			    rtcInitOccludedArguments(&sargs);
			    sargs.feature_mask = RTC_FEATURE_FLAG_TRIANGLE;
			    rtcOccluded1(data.g_scene, RTCRay_(shadowRay), &sargs);
			    RayStats_addShadowRay(stats);

                shadow.tfar >= is not occluded


                please use data.max_path_length, NEE, brdfSampling and mis variables to control the path-tracing algorithm. it will facilitate the evaluation process :) 
            */
        }
    }

    return L;
}
