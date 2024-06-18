// Physically based shading model
// parameterized with the below options
// [ Karis 2013, "Real Shading in Unreal Engine 4" slide 11 ]

// E = Random sample for BRDF.
// N = Normal of the macro surface.
// H = Normal of the micro surface.
// V = View vector going from surface's position towards the view's origin.
// L = Light ray direction

// D = Microfacet NDF
// G = Shadowing and masking
// F = Fresnel

// Vis = G / (4*NoL*NoV)
// f = Microfacet specular BRDF = D*G*F / (4*NoL*NoV) = D*Vis*F
// -------------------------------------------------------------------------------

float3 main(float NoL, float NoV, float VoL, float Roughness, float3 SpecularColor)
{
	//Init
		float InvLenH = rsqrt( 2 + 2 * VoL );
		float NoH = saturate( ( NoL + NoV ) * InvLenH );
		float VoH = saturate( InvLenH + InvLenH * VoL );
		
		NoL = saturate( NoL );
		NoV = saturate( abs( NoV ) + 1e-5 );


	float a2 = Pow4( Roughness );

	// TODO определить
	float Energy = 1; // = EnergyNormalization( a2, Context.VoH);

	// =========================================
	// Generalized microfacet specular

	// GGX / Trowbridge-Reitz
	// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
		float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
	float D_GGX = a2 / ( PI*d*d );					// 4 mul, 1 rcp
	float D = D_GGX * Energy;	// float D = D_GGX( a2, Context.NoH ) * Energy;

	// Appoximation of joint Smith term for GGX
	// [Heitz 2014, "Understanding the Masking-Shadowing Function in Microfacet-Based BRDFs"]
		float a = sqrt(a2);
		float Vis_SmithV = NoL * ( NoV * ( 1 - a ) + a );
		float Vis_SmithL = NoV * ( NoL * ( 1 - a ) + a );
	float Vis_SmithJointApprox = 0.5 * rcp( Vis_SmithV + Vis_SmithL );
	float Vis = Vis_SmithJointApprox;

	// [Schlick 1994, "An Inexpensive BRDF Model for Physically-Based Rendering"]
		float Fc = Pow5( 1 - VoH );					// 1 sub, 3 mul
		//return Fc + (1 - Fc) * SpecularColor;		// 1 add, 3 mad
		// Anything less than 2% is physically impossible and is instead considered to be shadowing
	float3 F_Schlick = saturate( 50.0 * SpecularColor.g ) * Fc + (1 - Fc) * SpecularColor;
	float3 F = F_Schlick;

	float3 SpecularGGX = (D * Vis) * F;

	return SpecularGGX;
}