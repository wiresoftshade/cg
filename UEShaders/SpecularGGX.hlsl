struct BxDFContext
{
	half NoV;
	half NoL;
	half VoL;
	half NoH;
	half VoH;
	half XoV;
	half XoL;
	half XoH;
	half YoV;
	half YoL;
	half YoH;
};

void Init( inout BxDFContext Context, half3 N, half3 V, half3 L )
{
	Context.NoL = dot(N, L);
	Context.NoV = dot(N, V);
	Context.VoL = dot(V, L);
	float InvLenH = rsqrt( 2 + 2 * Context.VoL );
	Context.NoH = saturate( ( Context.NoL + Context.NoV ) * InvLenH );
	Context.VoH = saturate( InvLenH + InvLenH * Context.VoL );
	//NoL = saturate( NoL );
	//NoV = saturate( abs( NoV ) + 1e-5 );

	Context.XoV = 0.0f;
	Context.XoL = 0.0f;
	Context.XoH = 0.0f;
	Context.YoV = 0.0f;
	Context.YoL = 0.0f;
	Context.YoH = 0.0f;
}

float Pow2(float x)
{
    return x*x;
}

float Pow4(float x)
{
    float xx = x*x;
    return xx*xx;
}

float Pow5( float x )
{
	float xx = x*x;
	return xx * xx * x;
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

float New_a2( float a2, float SinAlpha, float VoH )
{
	return a2 + 0.25 * SinAlpha * (3.0 * sqrtFast(a2) + SinAlpha) / ( VoH + 0.001 );
}

float EnergyNormalization( inout float a2, float VoH)
{
	// imitation 
	float AreaLight_SphereSinAlphaSoft = 0;
	float AreaLight_SphereSinAlpha = 0;
	float AreaLight_LineCosSubtended = 0;


	float Sphere_a2 = a2;
	float Energy = 1;

	if( AreaLight_LineCosSubtended < 1 )
	{
		float LineCosTwoAlpha = AreaLight_LineCosSubtended;
		float LineTanAlpha = sqrt( ( 1.0001 - LineCosTwoAlpha ) / ( 1 + LineCosTwoAlpha ) );
		float Line_a2 = New_a2( Sphere_a2, LineTanAlpha, VoH );
		Energy *= sqrt( Sphere_a2 / Line_a2 );
	}

	return Energy;
}

const static float PI = 3.1415926535897932f;

// GGX / Trowbridge-Reitz
// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
float D_GGX( float a2, float NoH )
{
	float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
	return a2 / ( PI*d*d );					// 4 mul, 1 rcp
}

// Appoximation of joint Smith term for GGX
// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
float Vis_SmithJointApprox( float a2, float NoV, float NoL )
{
	float a = sqrt(a2);
	float Vis_SmithV = NoL * ( NoV * ( 1 - a ) + a );
	float Vis_SmithL = NoV * ( NoL * ( 1 - a ) + a );
	return 0.5 * rcp( Vis_SmithV + Vis_SmithL );
}
// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
float3 F_Schlick( float3 SpecularColor, float VoH )
{
	float Fc = Pow5( 1 - VoH );					// 1 sub, 3 mul
	//return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad
	
	// Anything less than 2% is physically impossible and is instead considered to be shadowing
	return saturate( 50.0 * SpecularColor.g ) * Fc + (1 - Fc) * SpecularColor;
}


float3 SpecularGGX( float Roughness, float3 SpecularColor, BxDFContext Context, half NoL)
{
	float a2 = Pow4( Roughness );
	//float Energy = EnergyNormalization( a2, Context.VoH);
	
	// Generalized microfacet specular
	float D = D_GGX( a2, Context.NoH );	// float D = D_GGX( a2, Context.NoH ) * Energy;
	float Vis = Vis_SmithJointApprox( a2, Context.NoV, NoL );
	float3 F = F_Schlick( SpecularColor, Context.VoH );

	return (D * Vis) * F;
}