#include "Application2.h"
#include <cmath>

void Application2::initScene() {
    Data_Constructor(&data, 1, 8);

    /* select scene here */
    gnomeScene();
    // horseScene();
    // heterogenousScene();
}

void Application2::gnomeScene() {
    FileName file = workingDir + FileName("Framework/scenes/gnome/garden_gnome.obj");

    /* set default camera */
    camera.from = Vec3fa(-0.07894, -0.414116, -1.40016);
    camera.to = camera.from + Vec3fa(0.0, 0.0, 1.0);
    speed = 0.005;

    Ref<SceneGraph::GroupNode> sceneGraph = loadOBJ(file, false).cast<SceneGraph::GroupNode>();
    auto light = new SceneGraph::LightNodeImpl<SceneGraph::PointLight>(
        SceneGraph::PointLight(Vec3fa(-0.1, -0.065, 0.21), Vec3fa(10, 10, 10)));
    sceneGraph->add(light);

    Ref<SceneGraph::GroupNode> flattened_scene = SceneGraph::flatten(sceneGraph, SceneGraph::INSTANCING_NONE);
    Scene* scene = new Scene;
    scene->add(flattened_scene);
    sceneGraph = nullptr;
    flattened_scene = nullptr;

    auto renderScene = new RenderScene(g_device, scene);
    g_render_scene = renderScene;
    data.scene = renderScene;
    data.densityGrid = nullptr;
    data.tempGrid = nullptr;
    scene = nullptr;
}

void Application2::horseScene() {
    FileName file = workingDir + FileName("Framework/scenes/horse/horse.obj");

    /* set default camera */
    camera.from = Vec3fa(0, 0.0, -0.5);
    camera.to = Vec3fa(0.0, 0.0, 0.0);
    // speed = 0.005;

    Ref<SceneGraph::GroupNode> sceneGraph = loadOBJ(file, false).cast<SceneGraph::GroupNode>();
    auto light = new SceneGraph::QuadLightMesh(Vec3fa(-0.25, 0.5, 0), Vec3fa(0.25, 0.5, 0.5),
                                               Vec3fa(0.25, 0.5, 0),
                                               Vec3fa(-0.25, 0.5, 0.5), Vec3fa(5, 5, 5));
    sceneGraph->add(light);

    Ref<SceneGraph::GroupNode> flattened_scene = SceneGraph::flatten(sceneGraph, SceneGraph::INSTANCING_NONE);
    Scene* scene = new Scene;
    scene->add(flattened_scene);
    sceneGraph = nullptr;
    flattened_scene = nullptr;

    auto renderScene = new RenderScene(g_device, scene);
    g_render_scene = renderScene;
    data.scene = renderScene;
    data.densityGrid = nullptr;
    data.tempGrid = nullptr;
    scene = nullptr;
}

void Application2::heterogenousScene() {
    FileName file = workingDir + FileName("Framework/scenes/box.obj");

    /* set default camera */
    camera.from = Vec3fa(0, 0.0, -2);
    camera.to = Vec3fa(0.0, 0.0, 0.0);

    Ref<SceneGraph::GroupNode> sceneGraph = loadOBJ(file, false).cast<SceneGraph::GroupNode>();
    auto light = new SceneGraph::QuadLightMesh(Vec3fa(-1, 2, -1), Vec3fa(1, 2, 1),
                                               Vec3fa(1, 2, -1),
                                               Vec3fa(-1, 2, 1), Vec3fa(1, 1, 1));
    sceneGraph->add(light);

    Ref<SceneGraph::GroupNode> flattened_scene = SceneGraph::flatten(sceneGraph, SceneGraph::INSTANCING_NONE);
    Scene* scene = new Scene;
    scene->add(flattened_scene);
    sceneGraph = nullptr;
    flattened_scene = nullptr;

    auto renderScene = new RenderScene(g_device, scene);

    Vec3fa worldPos(-0.5, -0.5, -0.5); // Corner of the Cornell Box
    Vec3fa scale(1, 1, 1); // Calculated scale
    FileName filegrid = workingDir + FileName("Framework/scenes/fire/density.vol");
    data.densityGrid = new Grid(filegrid.c_str(), Vec3ia(76, 184, 80), worldPos, scale);
    FileName filegrid2 = workingDir + FileName("Framework/scenes/fire/temperature.vol");
    data.tempGrid = new Grid(filegrid2.c_str(), Vec3ia(76, 184, 80), worldPos, scale);

    g_render_scene = renderScene;
    data.scene = renderScene;
    scene = nullptr;
}

Vec3fa ACESFilm(Vec3fa x, float exposure) {
    const Vec3fa a = Vec3fa(2.51f);
    const Vec3fa b = Vec3fa(0.03f);
    const Vec3fa c = Vec3fa(2.43f);
    const Vec3fa d = Vec3fa(0.59f);
    const Vec3fa e = Vec3fa(0.14f);

    x *= exposure;

    return (x * (a * x + b)) / (x * (c * x + d) + e);
}

/* task that renders a single screen tile */
Vec3fa Application2::renderPixel(float x, float y, const ISPCCamera& camera, RayStats& stats, RandomSampler& sampler) {
    /* radiance accumulator and weight */
    Vec3fa L = Vec3fa(0.0f);
    Vec3fa Lw = Vec3fa(1.0f);

    float transmittance = 1.0f;

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
            return L;
        } else {
            sample.Ng = face_forward(ray.dir, normalize(sample.Ng));
            sample.Ns = face_forward(ray.dir, normalize(sample.Ns));

            /* calculate BRDF */
            BRDF brdf;
            std::vector<Material *> material_array = data.scene->materials;
            Material__preprocess(material_array, matId, brdf, wo, sample);

            /* test if volume bounding box */
            if (brdf.name == "default") {
                if (boundingBox) {
                    return {1, 0, 0};
                }

                /* non scattering raymarch implementation */
                Ray secondary(sample.P, ray.dir, 0.001f, inf, 0.0f);

                /* trace secondary ray */
                rtcInitIntersectArguments(&iargs);
                iargs.feature_mask = RTC_FEATURE_FLAG_TRIANGLE;
                rtcIntersect1(data.g_scene, RTCRayHit_(secondary), &iargs);
                RayStats_addRay(stats);

                if (secondary.geomID != RTC_INVALID_GEOMETRY_ID) {
                    int num_steps = 100;
                    Vec3fa p_c = secondary.org;
                    Vec3fa end = secondary.org + secondary.tfar * secondary.dir;
                    Vec3fa step = (end - p_c) / num_steps;
                    float step_length = embree::length(step);
                    for (int i = 0; i < num_steps; i++) {
                        float density = 0;
                        if (data.densityGrid) {
                            density = data.densityGrid->sampleW(p_c); // Sample density from the grid
                        }
                        float temp = 0;
                        if (data.tempGrid) {
                            temp = data.tempGrid->sampleW(p_c); // Sample density from the grid
                        }

                        float g = 0.8; // asymmetry factor of the phase function
                        float angle = 1.0;

                        // HG phase function
                        float p = phase(g, angle);
                        float pdf;
                        Vec3fa dir = sample_phase_function(-ray.dir, g, RandomSampler_get2D(sampler), pdf);

                        // if -1.0 it means that we're out of the bounding box of the grid
                        if (density != -1.0f) {
                            density *= 10;
                            float redWavelength = 700;
                            float greenWavelength = 530;
                            float blueWavelength = 470;
                            Vec3fa emissive = Vec3fa(0.0, 0.0, 0.0);
                            if (temp != -1.0f && temp > 0.001) {
                                temp *= 1000;
                                emissive = Vec3f(blackbody_radiance_normalized(redWavelength, temp),
                                                 blackbody_radiance_normalized(greenWavelength, temp),
                                                 blackbody_radiance_normalized(blueWavelength, temp));
                            }
                            transmittance *= std::exp(-density * step_length);
                            // Update transmittance using exponential decay
                            L += emissive * transmittance;
                        }
                        p_c += step; // Move to the next point along the ray
                    }

                    Ray light(secondary.org + secondary.tfar * secondary.dir, ray.dir, 0.001f, inf, 0.0f);

                    /* trace light ray after medium escaped */
                    rtcInitIntersectArguments(&iargs);
                    iargs.feature_mask = RTC_FEATURE_FLAG_TRIANGLE;
                    rtcIntersect1(data.g_scene, RTCRayHit_(light), &iargs);
                    RayStats_addRay(stats);

                    if (light.geomID != RTC_INVALID_GEOMETRY_ID) {
                        unsigned lightID2 = data.scene->geometries[light.geomID]->lightID;
                        if (lightID2 != unsigned(-1)) {
                            const Light* l = data.scene->lights[lightID2];
                            Light_EvalRes evalRes = Lights_eval(l, sample, -wo);

                            L += evalRes.value * transmittance;
                            return L;
                        }
                    }
                }
            } else {
                /* sample BRDF at hit point */
                Sample3f wi1;
                Material__sample(material_array, matId, brdf, Lw, wo, sample, wi1, RandomSampler_get2D(sampler));

                int id = (int) (RandomSampler_get1D(sampler) * data.scene->lights.size());
                if (id == data.scene->lights.size())
                    id = data.scene->lights.size() - 1;
                const Light* l = data.scene->lights[id];

                Light_SampleRes ls = Lights_sample(l, sample, RandomSampler_get2D(sampler));

                Vec3fa diffuse = Material__eval(material_array, matId, brdf, wo, sample, ls.dir);


                /* initialize shadow ray */
                Ray shadow(sample.P, ls.dir, 0.001f, ls.dist - 0.001f, 0.0f);

                /* trace shadow ray */
                RTCOccludedArguments sargs;
                rtcInitOccludedArguments(&sargs);
                sargs.feature_mask = RTC_FEATURE_FLAG_TRIANGLE;
                rtcOccluded1(data.g_scene, RTCRay_(shadow), &sargs);
                RayStats_addShadowRay(stats);

                if (shadow.tfar >= 0.0f) {
                    L += diffuse * ls.weight;
                }
            }
        }
    }

    return ACESFilm(L, 1);
}
