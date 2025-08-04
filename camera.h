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

#ifndef __CAMERA_H
#define __CAMERA_H

#include "stdafx.h"

using namespace glm;

class Camera 
{
public:
	float ratio;
	float fov;
	float radians;
	float camNear, camFar;
	float wd2;
	float ndfl;
	float focallength;
	float eyesep;

	mat4x4	matMV, matP, matVP, matMVP, matV, matNrml;
	vec3 	camPos, camTgt, camUp, camRight;

public:
	Camera()
	{
		int w, h;
		extern GLFWwindow *glfwWindow;
		glfwGetWindowSize( glfwWindow, &w, &h );

		ratio	= (float)w / (float)h;
		fov		= 45.0f;
		radians = (float)M_PI / 180.0f * fov / 2.0f;
		camNear = 0.01f;
		camFar	= 500.0f;
		eyesep	= 0.05f;
		focallength = 2.5f;
		wd2  = camNear * tanf(radians);
		ndfl = camNear / focallength;
	}

	void setStereoParameters( float focalLength, float eyeSep )
	{
		focallength = focalLength;
		eyesep = eyeSep;
	}

	void computeMatrices( TrackBall *trackball, mat4x4 matM, int monostereo = 0 )
	{
		wd2 = camNear * tanf(radians);
		ndfl = camNear / focallength;

		vec3 r = normalize( cross( trackball->getCameraTarget() - trackball->getCameraPosition(), trackball->getCameraUp() ) );

		r *= eyesep / 2.0f;

		float left, right, top, bottom;
		if ( monostereo == 0 )
		{
			r *= 0.0f;
			left  = - ratio * wd2;
			right =   ratio * wd2;
		} else {
			if ( monostereo == 1 ) {
				left  = - ratio * wd2 - 0.5f * eyesep * ndfl;
				right =   ratio * wd2 - 0.5f * eyesep * ndfl;
			} else {
				left  = - ratio * wd2 + 0.5f * eyesep * ndfl;
				right =   ratio * wd2 + 0.5f * eyesep * ndfl;
				r *= -1.0f;
			}
		}
		top    =   wd2;
		bottom = - wd2;
		matP = frustum( left, right, bottom, top, camNear, camFar );

		matV = lookAt( 
			trackball->getCameraPosition() + r,
			trackball->getCameraTarget() + r, 
			trackball->getCameraUp() );

		matV *= trackball->getStrafeMatrix();

		matMV = matV * matM;
		matVP = matP * matV;
		matMVP = matVP * matM;

		matNrml = matM;
		matNrml = inverse( matNrml );
		matNrml = transpose( matNrml );

		camPos = trackball->getCameraPosition();
		camTgt = trackball->getCameraTarget();
		camUp  = trackball->getCameraUp();
		camRight = trackball->getCameraRight();
	}
};


#endif
