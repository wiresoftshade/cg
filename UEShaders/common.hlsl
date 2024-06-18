#pragma once

#define MaterialFloat float
#define MaterialFloat2 float2
#define MaterialFloat3 float3
#define MaterialFloat4 float4

const static float PI = 3.1415926535897932f;

#define POW_CLAMP 0.000001f

// Clamp the base, so it's never <= 0.0f (INF/NaN).
MaterialFloat ClampedPow(MaterialFloat X,MaterialFloat Y)
{
	return pow(max(abs(X),POW_CLAMP),Y);
}
MaterialFloat2 ClampedPow(MaterialFloat2 X,MaterialFloat2 Y)
{
	return pow(max(abs(X),MaterialFloat2(POW_CLAMP,POW_CLAMP)),Y);
}
MaterialFloat3 ClampedPow(MaterialFloat3 X,MaterialFloat3 Y)
{
	return pow(max(abs(X),MaterialFloat3(POW_CLAMP,POW_CLAMP,POW_CLAMP)),Y);
}  
MaterialFloat4 ClampedPow(MaterialFloat4 X,MaterialFloat4 Y)
{
	return pow(max(abs(X),MaterialFloat4(POW_CLAMP,POW_CLAMP,POW_CLAMP,POW_CLAMP)),Y);
} 

/** 
 * Use this function to compute the pow() in the specular computation.
 * This allows to change the implementation depending on platform or it easily can be replaced by some approxmation.
 */
float PhongShadingPow(float X, float Y)
{
	// The following clamping is done to prevent NaN being the result of the specular power computation.
	// Clamping has a minor performance cost.

	// In HLSL pow(a, b) is implemented as exp2(log2(a) * b).

	// For a=0 this becomes exp2(-inf * 0) = exp2(NaN) = NaN.

	// As seen in #TTP 160394 "QA Regression: PS3: Some maps have black pixelated artifacting."
	// this can cause severe image artifacts (problem was caused by specular power of 0, lightshafts propagated this to other pixels).
	// The problem appeared on PlayStation 3 but can also happen on similar PC NVidia hardware.

	// In order to avoid platform differences and rarely occuring image atrifacts we clamp the base.

	// Note: Clamping the exponent seemed to fix the issue mentioned TTP but we decided to fix the root and accept the
	// minor performance cost.

	return ClampedPow(X, Y);
}

float Square( float x )
{
	return x*x;
}

float2 Square( float2 x )
{
	return x*x;
}

float3 Square( float3 x )
{
	return x*x;
}

float4 Square( float4 x )
{
	return x*x;
}

float Pow2( float x )
{
	return x*x;
}

float2 Pow2( float2 x )
{
	return x*x;
}

float3 Pow2( float3 x )
{
	return x*x;
}

float4 Pow2( float4 x )
{
	return x*x;
}

float Pow4( float x )
{
	float xx = x*x;
	return xx * xx;
}

float2 Pow4( float2 x )
{
	float2 xx = x*x;
	return xx * xx;
}

float3 Pow4( float3 x )
{
	float3 xx = x*x;
	return xx * xx;
}

float4 Pow4( float4 x )
{
	float4 xx = x*x;
	return xx * xx;
}

float Pow5( float x )
{
	float xx = x*x;
	return xx * xx * x;
}

float2 Pow5( float2 x )
{
	float2 xx = x*x;
	return xx * xx * x;
}

float3 Pow5( float3 x )
{
	float3 xx = x*x;
	return xx * xx * x;
}

float4 Pow5( float4 x )
{
	float4 xx = x*x;
	return xx * xx * x;
}

// Relative error : ~3.4% over full
// Precise format : ~small float
// 2 ALU
float rsqrtFast( float x )
{
	int i = asint(x);
	i = 0x5f3759df - (i >> 1);
	return asfloat(i);
}

// Relative error : < 0.7% over full
// Precise format : ~small float
// 1 ALU
float sqrtFast( float x )
{
	int i = asint(x);
	i = 0x1FBD1DF5 + (i >> 1);
	return asfloat(i);
}

// Relative error : < 0.4% over full
// Precise format : ~small float
// 1 ALU
float rcpFast( float x )
{
	int i = asint(x);
	i = 0x7EF311C2 - i;
	return asfloat(i);
}