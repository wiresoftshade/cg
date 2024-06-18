#pragma once

struct FRect
{
	float3		Origin;
	float3x3	Axis;
	float2		Extent;
	float2		FullExtent;
	float2		Offset;
};

struct FRectLTC
{
	float3x3 LTC;
	float3x3 InvLTC;
	float3 IrradianceScale;
};

// Rect light texture data
struct FRectTexture
{
	half2 AtlasUVOffset;
	half2 AtlasUVScale;
	half  AtlasMaxLevel;
};


struct FAreaLight
{
	float		SphereSinAlpha;
	float		SphereSinAlphaSoft;
	float		LineCosSubtended;

	float3		FalloffColor;

	FRect		Rect;
	FRectTexture Texture;

	uint		IsRectAndDiffuseMicroReflWeight;
};

bool IsRectLight(FAreaLight AreaLight)
{
	return (AreaLight.IsRectAndDiffuseMicroReflWeight & 0x00000001) == 0x1;
}

// Integrated a GGX-based BSDF with a rect light using LTC
float3 RectGGXApproxLTC( float Roughness, float3 SpecularColor, half3 N, float3 V, FRect Rect, FRectTexture RectTexture, inout float3 OutMeanLightWorldDirection)
{
	// No visibile rect light due to barn door occlusion
	if (Rect.Extent.x == 0 || Rect.Extent.y == 0) return 0;

	const float NoV = saturate( abs( dot(N, V) ) + 1e-5 );

	const FRectLTC LTC = GetRectLTC_GGX(Roughness, SpecularColor, NoV);
	return RectApproxLTC(LTC, N, V, Rect, RectTexture, OutMeanLightWorldDirection);
}

float3 RectGGXApproxLTC(float Roughness, float3 SpecularColor, half3 N, float3 V, FRect Rect, FRectTexture RectTexture)
{
	float3 MeanLightWorldDirection = 0.0f;
	return RectGGXApproxLTC(Roughness, SpecularColor, N, V, Rect, RectTexture, MeanLightWorldDirection);
}
