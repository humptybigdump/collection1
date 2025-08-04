/*
	________             _____      ________________________
	___  __ \______________  /________  ____/__  /___  ____/
	__  /_/ /_  ___/  __ \  __/  __ \  / __ __  / __  /_
	_  ____/_  /   / /_/ / /_ / /_/ / /_/ / _  /___  __/
	/_/     /_/    \____/\__/ \____/\____/  /_____/_/

   ___/ minimalistic prototyping framework for OpenGL demos and practical courses
   ___/ Carsten Dachsbacher
   ___/ (ASCII font generator: http://patorjk.com/software/taag/)

   ___/ this is very ugly code for BVH generation and linearization (for storing in SSBOs)
   ___/ if you attended my lecture you should know how to do it better!

*/

#ifndef ACCEL2__H
#define ACCEL2__H

#include "stdafx.h"
#include <algorithm>
#include <cmath>

#define STACKLESS_BVH

#define _SAH_CANDIDATES 8
#define MAX_TRIANGLES_PER_LEAF	4

inline int isinfinite(float x)
{
	if ( ( x == x ) && ( ( x - x ) != 0.0f ) ) 
		return ( x < 0.0f ? -1 : 1 ); 
	return 0;
}

static 	vec3 f3min( const vec3 &a, const vec3 &b ) 
{
	return vec3( std::min( a.x, b.x ), std::min( a.y, b.y ), std::min( a.z, b.z ) );
}

static	vec3 f3max( const vec3 &a, const vec3 &b ) 
{
	return vec3( std::max( a.x, b.x ), std::max( a.y, b.y ), std::max( a.z, b.z ) );
}

class RayL;

#ifdef _MSC_VER
__declspec(align(4)) 
#endif

struct Material {
	float data[ 16 ];		// payload, depends on BxDF
};


struct Light {
	float emission[3];
	unsigned int triangleID;
	float invArea;
	unsigned int pad[3];
};


struct BITFLAG {
	BITFLAG() {
		f[0]=f[1]=f[2]=f[3]=0;
	}

	void setBit( int b ) {
		f[ b >> 5 ] |= (1<<(b&31));
	}

	void clearBit( int b ) {
		f[ b >> 5 ] &= ~(1<<(b&31));
	}

	int getBit( int b ) {
		int r = ( f[ b >> 5 ] & (1<<(b&31)) ) ? 1 : 0;
		return r;
	}

	unsigned int f[4];
};

struct TriangleL {
	vec3 a, b, c, n, e1, e2, n1, n2, n3;
	float uv[6];
	int sort;	// sorting criterion
	BITFLAG tempsort, sortflag; // sorting (temporary)
	float radSqr, area;
	int mat;
	vec3 emission;
};

struct LinearTriangle {
		float p0[3];
		int   material;
		float p1[3];
		int   pad0;
		float p2[3];
		int   pad1;
};

struct LinearTriangleData {
	float uv[ 6 ];
};

class RayL {
public:
	vec3 origin;
	vec3 direction, invDir;
	int dirIsNeg[3];
	float t, baryU, baryV;
	TriangleL *object;
	LinearTriangle *tri;

	RayL() {
	}

	RayL(const vec3 &eye, const vec3 &dir) {
		origin = eye;
		direction = dir;
		direction = normalize(dir);
	}

	RayL(const vec3 &orig, const vec3 &dir, float epsilon) {
		direction = normalize( dir );
		origin = orig + epsilon * direction;
	}
};





typedef float float3[3];

//
// flags: hasLeft, hasRight, if 00   >= child	4 Bit
//        splitAxis                             2 Bit
// #Triangles                                   8 Bit   // only for childs
// idxLeft und idxRight                         48 Bit  // only for inner node
// AABBs                                        48 Byte // only for inner node


struct LinearBVHNode {
	float3 aabb_left[2];
	float3 aabb_right[2];

	union {
		unsigned int firstTriangle;
		unsigned int idxLeft;
	};
	union {
		unsigned int idxRight;					// only lower 24 Bit
		unsigned int flags_axis_and_nTriangles;	// each 8-bit for flags
												// (1<<31 isChild), 
												// (1<<30 hasLeftChild), 
												// (1<<29 hasRightChild), 
												// axis, 2x 8 for nTriangles
	};
#ifdef STACKLESS_BVH
	unsigned int idxParent, idxSibling;
#endif
};

struct BVHNode {
	TriangleL *objects;
	int nTriangles;
	vec3 minAABB, maxAABB;
	BVHNode *left, *right;
	int nodeID;
	int splitAxis;
};

// using "octahedron environment maps" parameterization
static unsigned int encodeNormal( vec3 nrml, int bits ) 
{
	float scale = (float)( 1 << bits );

	vec3 d,d_;
			
	d = normalize( nrml );

	#define sign( x ) ( (x)>=0.0f ? 1.0f : -1.0f )
	d /= dot( vec3( 1.0f ), abs( d ) );

	if ( d.z < -1.0f + 1e-7f ) 
	{
		d.x = d.y = 1.0f;
	} else
	{
		// out-folding of the downward faces
		d_ = d;
		if ( d.z < 0.0f )
		{
			d_.x = (1-fabsf(d.y)) * sign(d.x);
			d_.y = (1-fabsf(d.x)) * sign(d.y);
			d = d_;
		}
	}
	// mapping to [0;1]ˆ2 texture space
	unsigned int i = (unsigned int)( (d.x*0.5f+0.5f) * (scale-1) );
	unsigned int j = (unsigned int)( (d.y*0.5f+0.5f) * (scale-1) );
	return (j << bits) | i;
}

// using "octahedron environment maps" parameterization
static vec3 decodeNormal( const unsigned int code, const int bits )
{
	float scale = (float)( 1 << bits );
	float x = (float)( code & ( (1<<bits)-1 ) ) / ((scale-1)*0.5f) - 1.0f;
	float y = (float)( code >> bits ) / ((scale-1)*0.5f) - 1.0f;
	float z = 1.0f - fabsf( x ) - fabsf( y );
	if ( z < 0.0f )
	{
		float sign_x = x >= 0.0f ? 1.0f : -1.0f;
		float sign_y = y >= 0.0f ? 1.0f : -1.0f;
		float x1 = x, y1 = y;
		x = ( 1.0f - fabsf( y1 ) ) * sign_x;
		y = ( 1.0f - fabsf( x1 ) ) * sign_y;
	}
	return normalize( vec3( x, y, z ) );
}

static void getExtend( const TriangleL *t, vec3 *minV, vec3 *maxV ) {
	*minV = f3min( t->a, f3min( t->b, t->c ) );
	*maxV = f3max( t->a, f3max( t->b, t->c ) );
};

static 	int SortPrimitiveX(const void* _left, const void* _right) {
		TriangleL* left = (TriangleL*)_left;
		TriangleL* right = (TriangleL*)_right;
		vec3 lc = ( left->a + left->b + left->c );
		vec3 rc = ( right->a + right->b + right->c );
		if ( lc.x < rc.x ) return -1;
		return 1;
	}
static 	int SortPrimitiveY(const void* _left, const void* _right) {
		TriangleL* left = (TriangleL*)_left;
		TriangleL* right = (TriangleL*)_right;
		vec3 lc = ( left->a + left->b + left->c );
		vec3 rc = ( right->a + right->b + right->c );
		if ( lc.y < rc.y ) return -1;
		return 1;
	}
static 	int SortPrimitiveZ(const void* _left, const void* _right) {
		TriangleL* left = (TriangleL*)_left;
		TriangleL* right = (TriangleL*)_right;
		vec3 lc = ( left->a + left->b + left->c );
		vec3 rc = ( right->a + right->b + right->c );
		if ( lc.z < rc.z ) return -1;
		return 1;
	}

static 	void getAABB( TriangleL* objects, int nObjects, vec3 *minAABB, vec3 *maxAABB ) {
		*minAABB = vec3( 1e37f );
		*maxAABB = vec3( -1e37f );

		vec3 minV, maxV;
		for ( int i = 0; i < nObjects; i++ ) {
			getExtend( &objects[ i ], &minV, &maxV );
			*minAABB = f3min( *minAABB, minV );
			*maxAABB = f3max( *maxAABB, maxV );
		}		
	}



static 	int SortPrimitive(const void* _left, const void* _right) {
		TriangleL* left = (TriangleL*)_left;
		TriangleL* right = (TriangleL*)_right;
		if ( left->sort > right->sort  ) return 1; 
		if ( left->sort < right->sort  ) return -1; 
		return 0;
	}

class BVHAcceleratorLinear 
{
public:
	int nNodes;
	BVHNode root;

	TriangleL *objects;

	LinearBVHNode *linearBVH;
	LinearTriangle *linearTriangles;
	LinearTriangleData *linearTriangleData;
	int nLinearNodes, nLinearTriangles;
	int nMaterials;
	Material matList[ 256 ];
	int nLights;
	Light lightList[ 256 ];

	BVHAcceleratorLinear() {
		nNodes = 0;
	}

	float computeSA( const vec3 &A, const vec3 &B ) {
		float a = B.x - A.x;
		float b = B.y - A.y;
		float c = B.z - A.z;
		return (a*b+b*c+a*c)*2.0f;
	}

	typedef int (*comp_func_ptr)(const void *, const void *);

	comp_func_ptr compareFunctions[ 3 ];

	#define MAX_TRIANGLES_OBJECT_SPLIT (4*512)

	void processNode( BVHNode *node, int depth ) 
	{

		vec3 right_min[ MAX_TRIANGLES_OBJECT_SPLIT ], right_max[ MAX_TRIANGLES_OBJECT_SPLIT ];

		#pragma omp critical(dataupdate)
		{		
			node->nodeID = nNodes;
			nNodes ++;
		}
		node->left = node->right = NULL;
		node->splitAxis = 0;

		if ( node->nTriangles < MAX_TRIANGLES_PER_LEAF )
			return;

		const float nodeSAH = 1.0f;
		float bestObjectSAH = 1e37f;

		float bestSAH = 1e37f;
		int bestCandidate = -1, bestNormal = -1, bestObjectSplit = -1;
		int bestObjectNormal = -1;

		const int nCandidates = _SAH_CANDIDATES;

		float SA = computeSA( node->minAABB, node->maxAABB );

		vec3 best_minVL, best_maxVL, best_minVR, best_maxVR;

		// get AABB of all triangle centers
		vec3 centerMaxAABB = vec3( -1e37f ), centerMinAABB = vec3( 1e37f );
		for ( int i = 0; i < node->nTriangles; i++ ) {
			vec3 center;
			TriangleL *object = &node->objects[ i ];
			center = ( object->a + object->b + object->c ) / 3.0f;
			centerMinAABB = f3min( center, centerMinAABB );
			centerMaxAABB = f3max( center, centerMaxAABB );
		}

		for ( int nrml = 0; nrml < 3; nrml ++ )
		{
			// try Object-Splitting if not small enough
			if ( node->nTriangles < MAX_TRIANGLES_OBJECT_SPLIT ) 
			{
				qsort( node->objects, node->nTriangles, sizeof( TriangleL ), compareFunctions[ nrml ] );

				vec3 track_left_max = vec3( -1e37f ), track_left_min = vec3( 1e37f );

				vec3 track_max = vec3( -1e37f ), track_min = vec3( 1e37f );

				for ( int i = node->nTriangles-1; i > 0; i-- ) {
					vec3 minV, maxV;
					TriangleL *object = &node->objects[ i ];
					getExtend( object, &minV, &maxV );

					track_min = f3min( minV, track_min );
					track_max = f3max( maxV, track_max );

					right_min[ i ] = track_min;
					right_max[ i ] = track_max;
				}

				for ( int i = 0; i < node->nTriangles-1; i++ ) {
					vec3 minV, maxV;
					TriangleL *object = &node->objects[ i ];
					getExtend( object, &minV, &maxV );

					track_left_min = f3min( minV, track_left_min );
					track_left_max = f3max( maxV, track_left_max );

					float SA_left  = computeSA( track_left_min, track_left_max );
					float SA_right = computeSA( right_min[ i+1 ], right_max[ i+1 ] );
					float curSAH   = nodeSAH + (i+1) * SA_left / SA + (node->nTriangles-i-1) * SA_right / SA;
					
					if ( curSAH < bestObjectSAH )
					{
						bestObjectSAH = curSAH;
						bestObjectSplit = i;
						bestObjectNormal = nrml;
						best_minVL = track_left_min;
						best_maxVL = track_left_max;
						best_minVR = right_min[i+1];
						best_maxVR = right_max[i+1];
					}
				}

			} 
			
#if 1
			else

			// SAH
			for ( int cand = 0; cand < nCandidates; cand ++ )
			{
				vec3 splitCenter = ( centerMaxAABB - centerMinAABB ) * (float)(cand+1) / (float)(nCandidates+1) + centerMinAABB;

				vec3 splitNrml = vec3( (nrml==0)?1.0f:0.0f, (nrml==1)?1.0f:0.0f, (nrml==2)?1.0f:0.0f );
				float splitValue = dot( splitCenter, splitNrml );

				vec3 minVL, maxVL, minVR, maxVR;
				minVL = minVR = vec3( 1e37f );
				maxVL = maxVR = vec3( -1e37f );

				int lls = 0, rrs = 0;
				vec3 minV, maxV, center;

				for ( int i = 0; i < node->nTriangles; i++ ) {
					TriangleL *object = &node->objects[ i ];
					getExtend( object, &minV, &maxV );
					center = ( object->a + object->b + object->c ) / 3.0f;

					float primLeft  = center[ nrml ] - splitValue; // positive if right from split plane
					float primRight = splitValue - center[ nrml ]; // positive if left from split plane

					if ( primLeft > primRight ) {
						rrs++;
						minVR = f3min( minV, minVR );
						maxVR = f3max( maxV, maxVR );
						object->sort |= 128;
					} else {
						lls++;
						minVL = f3min( minV, minVL );
						maxVL = f3max( maxV, maxVL );
						object->sort &= 127;
					} 
				}

				if ( lls > 0 && rrs > 0 ) 
				{
					float SA_left = computeSA( minVL, maxVL );
					float SA_right = computeSA( minVR, maxVR );

					float curSAH = nodeSAH + lls * SA_left / SA + rrs * SA_right / SA;
					if ( curSAH < bestSAH )
					{
						bestSAH = curSAH;
						bestCandidate = cand;
						bestNormal = nrml;
						best_minVL = minVL;
						best_maxVL = maxVL;
						best_minVR = minVR;
						best_maxVR = maxVR;

						for ( int i = 0; i < node->nTriangles; i++ ) 
							node->objects[ i ].sort >>= 7;
					}
				}
			}
#endif
		}
		////////////////////////////////////////////////////////////////////////////

		float leafSAH = (float)node->nTriangles;
		if ( leafSAH < bestSAH && leafSAH < bestObjectSAH ) 
		{
			return;
		}

		if ( bestObjectSAH < bestSAH && bestObjectSplit != -1 )
		{
			qsort( node->objects, node->nTriangles, sizeof( TriangleL ), compareFunctions[ bestObjectNormal ] );


			vec3 minVL, maxVL, minVR, maxVR;
			minVL = minVR = vec3( 1e37f );
			maxVL = maxVR = vec3( -1e37f );
			for ( int i = 0; i < bestObjectSplit + 1; i++ ) {
				vec3 minV, maxV;
				TriangleL *object = &node->objects[ i ];
				getExtend( object, &minV, &maxV );

				best_minVL = f3min( minV, best_minVL );
				best_maxVL = f3max( maxV, best_maxVL );
			}

			for ( int i = bestObjectSplit + 1; i < node->nTriangles; i++ ) {
				vec3 minV, maxV;
				TriangleL *object = &node->objects[ i ];
				getExtend( object, &minV, &maxV );

				best_minVR = f3min( minV, best_minVR );
				best_maxVR = f3max( maxV, best_maxVR );
			}

			{
				node->left = new BVHNode;
				node->left->nTriangles = bestObjectSplit + 1; 
				node->left->objects = node->objects;
				node->left->minAABB = best_minVL;
				node->left->maxAABB = best_maxVL;
			}
			{
				node->right = new BVHNode;
				node->right->nTriangles = (node->nTriangles-bestObjectSplit-1); 
				node->right->objects = &node->objects[ bestObjectSplit + 1 ]; 
				node->right->minAABB = best_minVR;
				node->right->maxAABB = best_maxVR;
			}
			node->splitAxis = bestObjectNormal;

			return;
		}

		// one of the SAH candidates won! -> do sorting
		vec3 splitCenter = ( centerMaxAABB - centerMinAABB ) * (float)(bestCandidate+1) / (float)(nCandidates+1) + centerMinAABB;
		node->splitAxis = bestNormal;

		vec3 splitNrml = vec3( (bestNormal==0)?1.0f:0.0f, (bestNormal==1)?1.0f:0.0f, (bestNormal==2)?1.0f:0.0f );
		float splitValue = dot( splitCenter, splitNrml );

		vec3 minVL, maxVL, minVR, maxVR;
		minVL = minVR = vec3( 1e37f );
		maxVL = maxVR = vec3( -1e37f );

		// for in-place sorting
		int nTriLeft = 0, nTriRight = 0;

		vec3 minV, maxV, center;

		for ( int i = 0; i < node->nTriangles; i++ ) {
			TriangleL *object = &node->objects[ i ];
			getExtend( object, &minV, &maxV );
			center = ( object->a + object->b + object->c ) / 3.0f;

			float primLeft  = center[ bestNormal ] - splitValue; // positive if right from split plane
			float primRight = splitValue - center[ bestNormal ]; // positive if left from split plane

			if ( primLeft > primRight ) {
				minVR = f3min( minV, minVR );
				maxVR = f3max( maxV, maxVR );

				object->sort = 1;
				nTriRight ++;
			} else {
				minVL = f3min( minV, minVL );
				maxVL = f3max( maxV, maxVL );

				object->sort = 0;
				nTriLeft ++;
			} 
		}

		//printf( "spatial split -> %d  %d\n", nTriLeft, nTriRight );
		qsort( node->objects, node->nTriangles, sizeof( TriangleL ), (SortPrimitive) );

		if ( nTriLeft > 0 ) {
			node->left = new BVHNode;
			node->left->nTriangles = nTriLeft;
			node->left->objects = node->objects;
			node->left->minAABB = minVL;
			node->left->maxAABB = maxVL;
		}
		if ( nTriRight > 0 ) {
			node->right = new BVHNode;
			node->right->nTriangles = nTriRight;
			node->right->objects = &node->objects[ nTriLeft ];
			node->right->minAABB = minVR;
			node->right->maxAABB = maxVR;
		}
	}

	void processLargeNode( BVHNode *node, int depth ) {

		#pragma omp critical(dataupdate)
		{
			node->nodeID = nNodes;
			nNodes ++;
		}

		node->left = node->right = NULL;
		node->splitAxis = 0;

		if ( node->nTriangles < MAX_TRIANGLES_PER_LEAF )
			return;

		float bestSAH = 1e37f;
		int bestCandidate = -1, bestNormal = -1;
		const int nCandidates = _SAH_CANDIDATES;

		vec3 best_minVL, best_maxVL, best_minVR, best_maxVR;
		int best_nTriLeft, best_nTriRight, bestTID;

		float SA = computeSA( node->minAABB, node->maxAABB );

		// get AABB of all triangle centers
		vec3 centerMaxAABB = vec3( -1e37f ), centerMinAABB = vec3( 1e37f );
		for ( int i = 0; i < node->nTriangles; i++ ) {
			vec3 center;
			TriangleL *object = &node->objects[ i ];
			center = ( object->a + object->b + object->c ) / 3.0f;
			centerMinAABB = f3min( center, centerMinAABB );
			centerMaxAABB = f3max( center, centerMaxAABB );
		}

		#pragma omp parallel for
		for ( int trial = 0; trial < 3 * nCandidates; trial ++ )
		{
			int nrml = trial % 3;
			int cand = trial / 3;

			vec3 splitNrml = vec3( (nrml==0)?1.0f:0.0f, (nrml==1)?1.0f:0.0f, (nrml==2)?1.0f:0.0f );

			// SAH
			vec3 splitCenter = ( centerMaxAABB - centerMinAABB ) * (float)(cand+1) / (float)(nCandidates+1) + centerMinAABB;
			float splitValue = dot( splitCenter, splitNrml );

			vec3 minVL, maxVL, minVR, maxVR;
			minVL = minVR = vec3( 1e37f );
			maxVL = maxVR = vec3( -1e37f );

			int lls = 0, rrs = 0;
			vec3 minV, maxV, center;

			int tid = trial;

			for ( int i = 0; i < node->nTriangles; i++ ) {
				TriangleL *object = &node->objects[ i ];
				getExtend( object, &minV, &maxV );
				center = ( object->a + object->b + object->c ) / 3.0f;

				float primLeft  = center[ nrml ] - splitValue; // positive if right from split plane
				float primRight = splitValue - center[ nrml ]; // positive if left from split plane

				if ( primLeft > primRight ) {
					rrs++;
					minVR = f3min( minV, minVR );
					maxVR = f3max( maxV, maxVR );
					#pragma omp critical(dataupdate)
					{
					object->tempsort.setBit( tid );
					}
				} else {
					lls++;
					minVL = f3min( minV, minVL );
					maxVL = f3max( maxV, maxVL );
					#pragma omp critical(dataupdate)
					{
					object->tempsort.clearBit( tid );
					}
				} 
			}

			if ( lls > 0 && rrs > 0 ) 
			{
				float SA_left = computeSA( minVL, maxVL );
				float SA_right = computeSA( minVR, maxVR );

				float curSAH = 1.0f + lls * SA_left / SA + rrs * SA_right / SA;

				#pragma omp critical(dataupdate)
				{		
					if ( curSAH < bestSAH )
					{
						for ( int i = 0; i < node->nTriangles; i++ ) {
							int sortflag = node->objects[ i ].tempsort.getBit( tid );
							node->objects[ i ].sortflag.clearBit( tid );
							if ( sortflag )
								node->objects[ i ].sortflag.setBit( tid );
							//int sortflag = node->objects[ i ].tempsort & (1 << tid );
							//node->objects[ i ].sort &= ~(1 << tid );
							//node->objects[ i ].sort |= sortflag;
						}

						bestSAH = curSAH;
						bestCandidate = cand;
						bestNormal = nrml;
						best_minVL = minVL;
						best_maxVL = maxVL;
						best_minVR = minVR;
						best_maxVR = maxVR;
						best_nTriLeft = lls;
						best_nTriRight = rrs;
						bestTID = tid;
					}
				}
			}
		}

		////////////////////////////////////////////////////////////////////////////
		if ( bestCandidate == -1 ) 
		{
			printf( " [BVH]: no best candidate split found, exiting :-(\n" );
			exit(1);
		}

		// in-place sorting
		for ( int i = 0; i < node->nTriangles; i++ ) {
			TriangleL *object = &node->objects[ i ];
			object->sort = object->sortflag.getBit( bestTID );
		}

		qsort( node->objects, node->nTriangles, sizeof( TriangleL ), (SortPrimitive) );

		if ( best_nTriLeft > 0 ) {
			node->left = new BVHNode;
			node->left->nTriangles = best_nTriLeft;
			node->left->objects = node->objects;
			node->left->minAABB = best_minVL;
			node->left->maxAABB = best_maxVL;
		}
		if ( best_nTriRight > 0 ) {
			node->right = new BVHNode;
			node->right->nTriangles = best_nTriRight;
			node->right->objects = &node->objects[ best_nTriLeft ];
			node->right->minAABB = best_minVR;
			node->right->maxAABB = best_maxVR;
		}
	}

	void buildRecursive1( BVHNode *node, int depth ) {
		processNode( node, depth );

		if ( node->left )
			buildRecursive1( node->left, depth + 1 );

		if ( node->right )
			buildRecursive1( node->right, depth + 1 );
	}

	void buildParallel( BVHNode *root ) {
		BVHNode *stack[ 64 ];
		int     depth[ 64 ];
		int     nNodesOnStack = 1;

		stack[ 0 ] = root;
		depth[ 0 ] = 0;

		compareFunctions[ 0 ] = SortPrimitiveX;
		compareFunctions[ 1 ] = SortPrimitiveY;
		compareFunctions[ 2 ] = SortPrimitiveZ;

		int NUM_THREADS = 32;

		omp_set_num_threads(NUM_THREADS);

		int nLargeNodes = 16;
		printf( " [BVH]: processing large nodes\n" );
		while ( nNodesOnStack < nLargeNodes ) {

			// process largest node
			int old_nNodesOnStack = nNodesOnStack;
			#pragma omp parallel for 
			for ( int idx = 0; idx < old_nNodesOnStack; idx ++ )
			{
				processLargeNode( stack[ idx ], depth[ idx ] );

				#pragma omp critical(dataupdate)
				{
					// add child nodes, remove parent node
					if ( stack[ idx ]->left != NULL && stack[ idx ]->right != NULL )
					{
						stack[ nNodesOnStack ] = stack[ idx ]->left;
						depth[ nNodesOnStack ] = depth[ idx ] + 1;
						nNodesOnStack ++;
						stack[ idx ] = stack[ idx ]->right;
						depth[ idx ] ++;
					} else
					if ( stack[ idx ]->left != NULL )
					{
						stack[ idx ] = stack[ idx ]->left;
						depth[ idx ] ++;
					} else
					if ( stack[ idx ]->right != NULL )
					{
						stack[ idx ] = stack[ idx ]->right;
						depth[ idx ] ++;
					}
				}
			}

			if ( old_nNodesOnStack >= nNodesOnStack )
				break;
		}

		omp_set_num_threads(NUM_THREADS);
		printf( " [BVH]: processing %d smaller nodes\n", nNodesOnStack );
		#pragma omp parallel for schedule (static, 1)
		for ( int i = 0; i < nNodesOnStack; i++ ) {
			buildRecursive1( stack[ i ], depth[ i ] );
		}
	}

	void buildRecursive( BVHNode *node, TriangleL* allObjects, int nObjects, int depth ) {
		node->nodeID = nNodes;
		nNodes ++;
		node->objects = allObjects;
		node->nTriangles = nObjects;
		node->left = node->right = NULL;
		node->splitAxis = 0;
		getAABB( allObjects, nObjects, &node->minAABB, &node->maxAABB );

		size_t s = node->nTriangles;
		if ( node->nTriangles < MAX_TRIANGLES_PER_LEAF )
			return;

		vec3 extend;
		extend.x = fabs( node->maxAABB.x - node->minAABB.x );
		extend.y = fabs( node->maxAABB.y - node->minAABB.y );
		extend.z = fabs( node->maxAABB.z - node->minAABB.z );

		std::vector<TriangleL> bestLeft, bestRight;
		std::vector<TriangleL> left, right;
		float bestSAH = 1e37f;
		int bestCandidate = -1, bestNormal = -1;
		const int nCandidates = 32;
		vec3 splitCenter;

		for ( int nrml = 0; nrml < 3; nrml ++ )
		{
			vec3 splitNrml = vec3( (nrml==0)?1.0f:0.0f, (nrml==1)?1.0f:0.0f, (nrml==2)?1.0f:0.0f );

			// SAH
			for ( int cand = 0; cand < nCandidates; cand ++ )
			{
				splitCenter = ( node->maxAABB - node->minAABB ) * (float)(cand+1) / (float)(nCandidates+1) + node->minAABB;
				float splitValue = dot( splitCenter, splitNrml );

				vec3 minVL, maxVL, minVR, maxVR;
				minVL = minVR = vec3( 1e37f );
				maxVL = maxVR = vec3( -1e37f );

				left.clear(); right.clear();

				int lls = 0, rrs = 0, n = 0;
				vec3 minV, maxV, center;

				for ( int i = 0; i < node->nTriangles; i++ ) {
					TriangleL *object = &node->objects[ i ];
					getExtend( object, &minV, &maxV );
					center = ( minV + maxV ) * 0.5f;

					n ++;

					float primLeft  = dot( center, splitNrml ) - splitValue; // positive if right from split plane
					float primRight = splitValue - dot( center, splitNrml ); // positive if left from split plane

					if ( primLeft > primRight ) {
						right.push_back( (*object) ); rrs++;
						minVR = f3min( minV, minVR );
						maxVR = f3max( maxV, maxVR );
					} else {
						left.push_back( (*object) ); lls++;
						minVL = f3min( minV, minVL );
						maxVL = f3max( maxV, maxVL );
					} 
				}

				if ( left.size() > 0 && right.size() > 0 )
				{
					float a = node->maxAABB.x - node->minAABB.x;
					float b = node->maxAABB.y - node->minAABB.y;
					float c = node->maxAABB.z - node->minAABB.z;
					float SA = a*b+b*c+a*c;
					float al = maxVL.x - minVL.x;
					float bl = maxVL.y - minVL.y;
					float cl = maxVL.z - minVL.z;
					float SA_left = al*bl+bl*cl+al*cl;
					float ar = maxVR.x - minVR.x;
					float br = maxVR.y - minVR.y;
					float cr = maxVR.z - minVR.z;
					float SA_right = ar*br+br*cr+ar*cr;
					float curSAH = 1.0f + left.size() * SA_left / SA + right.size() * SA_right / SA;
					if ( (SA_left != SA_left) || isinfinite (SA_right) )
						ar = ar;
					static int cnt = 0;
					if( cnt == 7972 )
						cnt = cnt;
					if ( curSAH < bestSAH )
					{
						bestSAH = curSAH;
						bestCandidate = cand;
						bestNormal = nrml;
						bestLeft = left;
						bestRight = right;
					}
				}
			}
		}
		////////////////////////////////////////////////////////////////////////////
		if ( bestCandidate == -1 ) {
			printf( " [BVH]: no best candidate split found.\n" );
			vec3 splitNrml = vec3( ((depth%3)==0)?1.0f:0.0f, ((depth%3)==1)?1.0f:0.0f, ((depth%3)==2)?1.0f:0.0f );

			splitCenter = ( node->maxAABB + node->minAABB ) * 0.5f;
			node->splitAxis = bestNormal = depth % 3;

			left.clear(); right.clear();

			int lls = 0, rrs = 0, n = 0;
			vec3 minV, maxV, center;

			for ( int i = 0; i < node->nTriangles; i++ ) {
				TriangleL *object = &node->objects[ i ];
				getExtend( object, &minV, &maxV );
				center = ( minV + maxV ) * 0.5f;

				n ++;
			
				if ( dot( center - splitCenter, splitNrml ) > 0.0f ) { // spatial-median
					right.push_back( (*object) ); rrs++;
				} else {
					left.push_back( (*object) ); lls++;
				}
			}
		} else {
			splitCenter = ( node->maxAABB - node->minAABB ) * (float)(bestCandidate+1) / (float)(nCandidates+1) + node->minAABB;
			left = bestLeft;
			right = bestRight;
			node->splitAxis = bestNormal;
		}

		int ls = (int)left.size();
		int rs = (int)right.size();
		if ( left.size() > 0 ) {
			node->left = new BVHNode;
			int nTriangles = 0;
			TriangleL *objects = new TriangleL[ ls ];
			std::vector<TriangleL>::iterator	tl;
			for ( tl = left.begin(); tl != left.end(); tl ++ ) 
				objects[ nTriangles ++ ] = (*tl);
			buildRecursive( node->left, objects, nTriangles, depth + 1 );
		}
		if ( right.size() > 0 ) {
			node->right = new BVHNode;
			int nTriangles = 0;
			TriangleL *objects = new TriangleL[ rs ];
			std::vector<TriangleL>::iterator	tr;
			for ( tr = right.begin(); tr != right.end(); tr ++ ) 
				objects[ nTriangles ++ ] = (*tr);
			buildRecursive( node->right, objects, nTriangles, depth + 1 );
		}
	}

	int totalNumberTriangles( BVHNode *node ) {
		if ( node->left == NULL && node->right == NULL ) {
			return node->nTriangles;
		} else {
			return totalNumberTriangles( node->left ) + totalNumberTriangles( node->right );
		}
	}

	int curTriangleIdx;
	int curNodeIdx;

	int linearizeBVHRecursive( BVHNode *node, int myIdx, int idxParent = -1, int idxSibling = -1 )
	{
		for ( int i = 0; i < 2; i++ )
			for ( int j = 0; j < 3; j++ )
			{
				linearBVH[ myIdx ].aabb_left[ i ][ j ] = 0.0f;
				linearBVH[ myIdx ].aabb_right[ i ][ j ] = 0.0f;
			}

		if ( node->left != NULL ) 
		{
			linearBVH[ myIdx ].aabb_left[ 0 ][ 0 ] = node->left->minAABB.x;
			linearBVH[ myIdx ].aabb_left[ 0 ][ 1 ] = node->left->minAABB.y;
			linearBVH[ myIdx ].aabb_left[ 0 ][ 2 ] = node->left->minAABB.z;
			linearBVH[ myIdx ].aabb_left[ 1 ][ 0 ] = node->left->maxAABB.x;
			linearBVH[ myIdx ].aabb_left[ 1 ][ 1 ] = node->left->maxAABB.y;
			linearBVH[ myIdx ].aabb_left[ 1 ][ 2 ] = node->left->maxAABB.z;
		}
		if ( node->right != NULL ) 
		{
			linearBVH[ myIdx ].aabb_right[ 0 ][ 0 ] = node->right->minAABB.x;
			linearBVH[ myIdx ].aabb_right[ 0 ][ 1 ] = node->right->minAABB.y;
			linearBVH[ myIdx ].aabb_right[ 0 ][ 2 ] = node->right->minAABB.z;
			linearBVH[ myIdx ].aabb_right[ 1 ][ 0 ] = node->right->maxAABB.x;
			linearBVH[ myIdx ].aabb_right[ 1 ][ 1 ] = node->right->maxAABB.y;
			linearBVH[ myIdx ].aabb_right[ 1 ][ 2 ] = node->right->maxAABB.z;
		}

		linearBVH[ myIdx ].flags_axis_and_nTriangles = 0; // ist auch idxRight

		linearBVH[ myIdx ].idxLeft = 0;
		linearBVH[ myIdx ].firstTriangle = 0;
		linearBVH[ myIdx ].flags_axis_and_nTriangles = 0;
		linearBVH[ myIdx ].flags_axis_and_nTriangles = (node->splitAxis << 24);

#ifdef STACKLESS_BVH
		linearBVH[ myIdx ].idxParent = idxParent;
		linearBVH[ myIdx ].idxSibling = idxSibling;
#endif		

		if ( node->left == NULL && node->right == NULL ) 
		{
			linearBVH[ myIdx ].flags_axis_and_nTriangles |= (1 << 31); // "isChild"

			linearBVH[ myIdx ].firstTriangle = curTriangleIdx;
			linearBVH[ myIdx ].flags_axis_and_nTriangles |= node->nTriangles;

			// copy triangles
			for ( int i = 0; i < node->nTriangles; i++ )
			{
				unsigned int material = node->objects[ i ].mat;

				unsigned int n1, n2, n3;

				// 10 bits per component, 2 components -> 20 bits per normal
				n1 = encodeNormal( node->objects[ i ].n1, 10 );
				n2 = encodeNormal( node->objects[ i ].n2, 10 );
				n3 = encodeNormal( node->objects[ i ].n3, 10 );

				vec3 nn1 = decodeNormal( n1, 10 );
				vec3 nn2 = decodeNormal( n2, 10 );
				vec3 nn3 = decodeNormal( n3, 10 );

				if ( dot( node->objects[ i ].n1, nn1 ) < 0.9f )
					n1 = n1;
				if ( dot( node->objects[ i ].n2, decodeNormal( n2, 10 ) ) < 0.9f )
				{
					n2 = encodeNormal( node->objects[ i ].n2, 10 );
					vec3 nn2 = decodeNormal( n2, 10 );
					n1 = n1;
				}
				if ( dot( node->objects[ i ].n3, decodeNormal( n3, 10 ) ) < 0.9f )
					n1 = n1;

				linearTriangles[ curTriangleIdx ].p0[ 0 ] = node->objects[ i ].a.x;
				linearTriangles[ curTriangleIdx ].p0[ 1 ] = node->objects[ i ].a.y;
				linearTriangles[ curTriangleIdx ].p0[ 2 ] = node->objects[ i ].a.z;
				unsigned int textureIdx = *(unsigned int*)&(matList[ material ].data[14]);
				linearTriangles[ curTriangleIdx ].material = material | ( (textureIdx&255) << 16 );
				linearTriangles[ curTriangleIdx ].p1[ 0 ] = node->objects[ i ].b.x;
				linearTriangles[ curTriangleIdx ].p1[ 1 ] = node->objects[ i ].b.y;
				linearTriangles[ curTriangleIdx ].p1[ 2 ] = node->objects[ i ].b.z;
				linearTriangles[ curTriangleIdx ].pad0 = ( (n2&1023) << 20 ) | n1;
				linearTriangles[ curTriangleIdx ].p2[ 0 ] = node->objects[ i ].c.x;
				linearTriangles[ curTriangleIdx ].p2[ 1 ] = node->objects[ i ].c.y;
				linearTriangles[ curTriangleIdx ].p2[ 2 ] = node->objects[ i ].c.z;
				linearTriangles[ curTriangleIdx ].pad1 = (n3<<10) | (n2>>10);

				for ( int u = 0; u < 6; u++ )
					linearTriangleData[ curTriangleIdx ].uv[ u ] = node->objects[ i ].uv[ u ];

				if ( length( node->objects[ i ].emission ) > 0.0f ) 
				{
					linearTriangles[ curTriangleIdx ].material = (1<<31) + nLights;
					printf( "light %d\n", nLights );
					if ( nLights < 256 )
					{
						lightList[ nLights ].triangleID = curTriangleIdx;
						lightList[ nLights ].invArea = 1.0f / node->objects[ i ].area;
						lightList[ nLights ].emission[ 0 ] = node->objects[ i ].emission.x * 50.0f;
						lightList[ nLights ].emission[ 1 ] = node->objects[ i ].emission.y * 50.0f;
						lightList[ nLights ].emission[ 2 ] = node->objects[ i ].emission.z * 50.0f;
						nLights ++;
					}
				}

				curTriangleIdx ++;

				if ( curTriangleIdx > nLinearTriangles )
				{
					printf( "problem1: %d   %d\n", curTriangleIdx, nLinearTriangles );
					exit(2);
				}
			}
		}

		int leftIdx = -1, rightIdx = -1;
		
		if ( node->left != NULL )
		{
			leftIdx = curNodeIdx;
			curNodeIdx ++;
		}
		if ( node->right != NULL )
		{
			rightIdx = curNodeIdx;
			curNodeIdx ++;
		}

		if ( node->left != NULL )
		{
			linearBVH[ myIdx ].flags_axis_and_nTriangles |= (1 << 30); // "hasLeftChild"
			linearBVH[ myIdx ].idxLeft = linearizeBVHRecursive( node->left, leftIdx, myIdx, rightIdx );
		}

		if ( node->right != NULL )
		{
			linearBVH[ myIdx ].flags_axis_and_nTriangles |= (1 << 29); // "hasRightChild"
			linearBVH[ myIdx ].idxRight |= linearizeBVHRecursive( node->right, rightIdx, myIdx, leftIdx );
		}

		return myIdx;
	}

	void 	linearizeBVH( BVHNode *node, int nTriangles )
	{
		curNodeIdx = curTriangleIdx = 0;
		linearBVH = new LinearBVHNode[ nNodes * 2 ];
		linearTriangles = new LinearTriangle[ nTriangles ];
		linearTriangleData = new LinearTriangleData[ nTriangles ];

		nLinearTriangles = nTriangles;
		nLights = 0;

		int nodeIdx = curNodeIdx;
		curNodeIdx ++;

		printf( " [BVH]: nodes %d, triangles %d\n", nNodes, nTriangles );
		linearizeBVHRecursive( node, nodeIdx );
		nLinearNodes = curNodeIdx;
	}

	void build( TriangleL* allObjects, int nObjects ) {
		nNodes = 0;
		root.objects = objects = allObjects;
		root.nTriangles = nObjects;
		for ( int i = 0; i < nObjects; i++ )
			allObjects[ i ].sort = 0;
		getAABB( root.objects, root.nTriangles, &root.minAABB, &root.maxAABB );
		buildParallel( &root );
		linearizeBVH( &root, nObjects );
	}

};


#endif