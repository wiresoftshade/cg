#include "defferedshading.hlsl"
#include "BRDF.hlsl"
#include "common.hlsl"
#include "arealight.hlsl"

struct FDirectLighting
{
	float3	Diffuse;
	float3	Specular;
	float3	Transmission;
};

struct FShadowTerms
{
	half	SurfaceShadow;
	half	TransmissionShadow;
	half	TransmissionThickness;
};


float New_a2( float a2, float SinAlpha, float VoH )
{
	return a2 + 0.25 * SinAlpha * (3.0 * sqrtFast(a2) + SinAlpha) / ( VoH + 0.001 );
	//return a2 + 0.25 * SinAlpha * ( saturate(12 * a2 + 0.125) + SinAlpha ) / ( VoH + 0.001 );
	//return a2 + 0.25 * SinAlpha * ( a2 * 2 + 1 + SinAlpha ) / ( VoH + 0.001 );
}

float EnergyNormalization( inout float a2, float VoH, FAreaLight AreaLight )
{
	if( AreaLight.SphereSinAlphaSoft > 0 )
	{
		// Modify Roughness
		a2 = saturate( a2 + Pow2( AreaLight.SphereSinAlphaSoft ) / ( VoH * 3.6 + 0.4 ) );
	}

	float Sphere_a2 = a2;
	float Energy = 1;
	if( AreaLight.SphereSinAlpha > 0 )
	{
		Sphere_a2 = New_a2( a2, AreaLight.SphereSinAlpha, VoH );
		Energy = a2 / Sphere_a2;
	}

	if( AreaLight.LineCosSubtended < 1 )
	{
#if 1
		float LineCosTwoAlpha = AreaLight.LineCosSubtended;
		float LineTanAlpha = sqrt( ( 1.0001 - LineCosTwoAlpha ) / ( 1 + LineCosTwoAlpha ) );
		float Line_a2 = New_a2( Sphere_a2, LineTanAlpha, VoH );
		Energy *= sqrt( Sphere_a2 / Line_a2 );
#else
		float LineCosTwoAlpha = AreaLight.LineCosSubtended;
		float LineSinAlpha = sqrt( 0.5 - 0.5 * LineCosTwoAlpha );
		float Line_a2 = New_a2( Sphere_a2, LineSinAlpha, VoH );
		Energy *= Sphere_a2 / Line_a2;
#endif
	}

	return Energy;
}

float3 SpecularGGX(float Roughness, float Anisotropy, float3 SpecularColor, BxDFContext Context, float NoL, FAreaLight AreaLight)
{
	float Alpha = Roughness * Roughness;
	float a2 = Alpha * Alpha;

	FAreaLight Punctual = AreaLight;
	Punctual.SphereSinAlpha = 0;
	Punctual.SphereSinAlphaSoft = 0;
	Punctual.LineCosSubtended = 1;
	Punctual.Rect = (FRect)0;
	Punctual.IsRectAndDiffuseMicroReflWeight = 0;

	float Energy = EnergyNormalization(a2, Context.VoH, Punctual);

	float ax = 0;
	float ay = 0;
	GetAnisotropicRoughness(Alpha, Anisotropy, ax, ay);

	// Generalized microfacet specular
	float3 D = D_GGXaniso(ax, ay, Context.NoH, Context.XoH, Context.YoH) * Energy;
	float3 Vis = Vis_SmithJointAniso(ax, ay, Context.NoV, NoL, Context.XoV, Context.XoL, Context.YoV, Context.YoL);
	float3 F = F_Schlick( SpecularColor, Context.VoH );

	return (D * Vis) * F;
}

float3 SpecularGGX( float Roughness, float3 SpecularColor, BxDFContext Context, half NoL, FAreaLight AreaLight )
{
	float a2 = Pow4( Roughness );
	float Energy = EnergyNormalization( a2, Context.VoH, AreaLight );
	
//#if SHADING_PATH_MOBILE
//	half D = D_GGX_Mobile(Roughness, Context.NoH) * Energy;
//	return MobileSpecularGGXInner(D, SpecularColor, Roughness, Context.NoV, NoL, Context.VoH, MOBILE_HIGH_QUALITY_BRDF);
//#else
	// Generalized microfacet specular
	float D = D_GGX( a2, Context.NoH ) * Energy;
	float Vis = Vis_SmithJointApprox( a2, Context.NoV, NoL );
	float3 F = F_Schlick( SpecularColor, Context.VoH );

	return (D * Vis) * F;
//#endif
}

FDirectLighting DefaultLitBxDF( FGBufferData GBuffer, half3 N, half3 V, half3 L, float Falloff, half NoL, FAreaLight AreaLight, FShadowTerms Shadow )
{
	BxDFContext Context;
	FDirectLighting Lighting;

#if SUPPORTS_ANISOTROPIC_MATERIALS
	bool bHasAnisotropy = HasAnisotropy(GBuffer.SelectiveOutputMask);
#else
	bool bHasAnisotropy = false;
#endif

	float NoV, VoH, NoH;
	//BRANCH
	if (bHasAnisotropy)
	{
		half3 X = GBuffer.WorldTangent;
		half3 Y = normalize(cross(N, X));
		Init(Context, N, X, Y, V, L);

		NoV = Context.NoV;
		VoH = Context.VoH;
		NoH = Context.NoH;
	}
	else
	{
#if SHADING_PATH_MOBILE
		InitMobile(Context, N, V, L, NoL);
#else
		Init(Context, N, V, L);
#endif

		NoV = Context.NoV;
		VoH = Context.VoH;
		NoH = Context.NoH;

		SphereMaxNoH(Context, AreaLight.SphereSinAlpha, true);
	}
    

	Context.NoV = saturate(abs( Context.NoV ) + 1e-5);

#if MATERIAL_ROUGHDIFFUSE
	// Chan diffuse model with roughness == specular roughness. This is not necessarily a good modelisation of reality because when the mean free path is super small, the diffuse can in fact looks rougher. But this is a start.
	// Also we cannot use the morphed context maximising NoH as this is causing visual artefact when interpolating rough/smooth diffuse response. 
	Lighting.Diffuse = Diffuse_Chan(GBuffer.DiffuseColor, Pow4(GBuffer.Roughness), NoV, NoL, VoH, NoH, GetAreaLightDiffuseMicroReflWeight(AreaLight));
#else
	Lighting.Diffuse = Diffuse_Lambert(GBuffer.DiffuseColor);
#endif
	Lighting.Diffuse *= AreaLight.FalloffColor * (Falloff * NoL);

	// BRANCH
	if (bHasAnisotropy)
	{
		//Lighting.Specular = GBuffer.WorldTangent * .5f + .5f;
		Lighting.Specular = AreaLight.FalloffColor * (Falloff * NoL) * SpecularGGX(GBuffer.Roughness, GBuffer.Anisotropy, GBuffer.SpecularColor, Context, NoL, AreaLight);
	}
	else
	{
		if( IsRectLight(AreaLight) )
		{
			Lighting.Specular = RectGGXApproxLTC(GBuffer.Roughness, GBuffer.SpecularColor, N, V, AreaLight.Rect, AreaLight.Texture);
		}
		else
		{
			Lighting.Specular = AreaLight.FalloffColor * (Falloff * NoL) * SpecularGGX(GBuffer.Roughness, GBuffer.SpecularColor, Context, NoL, AreaLight);
		}
	}

	// FBxDFEnergyTerms EnergyTerms = ComputeGGXSpecEnergyTerms(GBuffer.Roughness, Context.NoV, GBuffer.SpecularColor);

	// Add energy presevation (i.e. attenuation of the specular layer onto the diffuse component
	//Lighting.Diffuse *= ComputeEnergyPreservation(EnergyTerms);

	// Add specular microfacet multiple scattering term (energy-conservation)
	//Lighting.Specular *= ComputeEnergyConservation(EnergyTerms);

	Lighting.Transmission = 0;
	return Lighting;
}


