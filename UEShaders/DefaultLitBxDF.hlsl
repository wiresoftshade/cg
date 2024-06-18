/*
Do not finished becouse Need Area Ligth
But Area light not need for planet directional lighting
*/
struct FDirectLighting
{
	float3	Diffuse;
	float3	Specular;
	float3	Transmission;
};

struct FGBufferData
{
	float3	DiffuseColor;
	float	Roughness;
	float3	SpecularColor;
};

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

// [ de Carpentier 2017, "Decima Engine: Advances in Lighting and AA" ]
void SphereMaxNoH( inout BxDFContext Context, float SinAlpha, bool bNewtonIteration )
{
	if( SinAlpha > 0 )
	{
		float CosAlpha = sqrt( 1 - Pow2( SinAlpha ) );
	
		float RoL = 2 * Context.NoL * Context.NoV - Context.VoL;
		if( RoL >= CosAlpha )
		{
			Context.NoH = 1;
			Context.XoH = 0;
			Context.YoH = 0;
			Context.VoH = abs( Context.NoV );
		}
		else
		{
			float rInvLengthT = SinAlpha * rsqrt( 1 - RoL*RoL );
			float NoTr = rInvLengthT * ( Context.NoV - RoL * Context.NoL );
			// Enable once anisotropic materials support area lights
			#if 0
			float XoTr = rInvLengthT * ( Context.XoV - RoL * Context.XoL );
			float YoTr = rInvLengthT * ( Context.YoV - RoL * Context.YoL );
			#endif
			float VoTr = rInvLengthT * ( 2 * Context.NoV*Context.NoV - 1 - RoL * Context.VoL );

			if (bNewtonIteration)
			{
				// dot( cross(N,L), V )
				float NxLoV = sqrt( saturate( 1 - Pow2(Context.NoL) - Pow2(Context.NoV) - Pow2(Context.VoL) + 2 * Context.NoL * Context.NoV * Context.VoL ) );

				float NoBr = rInvLengthT * NxLoV;
				float VoBr = rInvLengthT * NxLoV * 2 * Context.NoV;

				float NoLVTr = Context.NoL * CosAlpha + Context.NoV + NoTr;
				float VoLVTr = Context.VoL * CosAlpha + 1   + VoTr;

				float p = NoBr   * VoLVTr;
				float q = NoLVTr * VoLVTr;
				float s = VoBr   * NoLVTr;

				float xNum = q * ( -0.5 * p + 0.25 * VoBr * NoLVTr );
				float xDenom = p*p + s * (s - 2*p) + NoLVTr * ( (Context.NoL * CosAlpha + Context.NoV) * Pow2(VoLVTr) + q * (-0.5 * (VoLVTr + Context.VoL * CosAlpha) - 0.5) );
				float TwoX1 = 2 * xNum / ( Pow2(xDenom) + Pow2(xNum) );
				float SinTheta = TwoX1 * xDenom;
				float CosTheta = 1.0 - TwoX1 * xNum;
				NoTr = CosTheta * NoTr + SinTheta * NoBr;
				VoTr = CosTheta * VoTr + SinTheta * VoBr;
			}

			Context.NoL = Context.NoL * CosAlpha + NoTr; // dot( N, L * CosAlpha + T * SinAlpha )
			// Enable once anisotropic materials support area lights
			#if 0
			Context.XoL = Context.XoL * CosAlpha + XoTr;
			Context.YoL = Context.YoL * CosAlpha + YoTr;
			#endif
			Context.VoL = Context.VoL * CosAlpha + VoTr;

			float InvLenH = rsqrt( 2 + 2 * Context.VoL );
			Context.NoH = saturate( ( Context.NoL + Context.NoV ) * InvLenH );
			// Enable once anisotropic materials support area lights
			#if 0
			Context.XoH = ((Context.XoL + Context.XoV) * InvLenH);	// dot(X, (L+V)/|L+V|)
			Context.YoH = ((Context.YoL + Context.YoV) * InvLenH);
			#endif
			Context.VoH = saturate( InvLenH + InvLenH * Context.VoL );
		}
	}
}

float3 DefaultLitBxDF( FGBufferData GBuffer, half3 N, half3 V, half3 L, float Falloff, half NoL)
{
	BxDFContext Context;
	FDirectLighting Lighting;

	bool bHasAnisotropy = false;

	float NoV, VoH, NoH;

	{
		Init(Context, N, V, L);

		NoV = Context.NoV;
		VoH = Context.VoH;
		NoH = Context.NoH;

		SphereMaxNoH(Context, AreaLight.SphereSinAlpha, true);
	}
    

	Context.NoV = saturate(abs( Context.NoV ) + 1e-5);

//has MATERIAL_ROUGHDIFFUSE
	// Chan diffuse model with roughness == specular roughness. This is not necessarily a good modelisation of reality because when the mean free path is super small, the diffuse can in fact looks rougher. But this is a start.
	// Also we cannot use the morphed context maximising NoH as this is causing visual artefact when interpolating rough/smooth diffuse response. 
	float3 Diffuse_Chan;
    float3 SpecularGGX;

    Lighting.Diffuse = Diffuse_Chan; // defined on input
	// Has Area light
    // Lighting.Diffuse *= AreaLight.FalloffColor * (Falloff * NoL);
    Lighting.Diffuse *= (Falloff * NoL);

	{
        // Has Area light
		// {
		// 	Lighting.Specular = AreaLight.FalloffColor * (Falloff * NoL) * SpecularGGX(GBuffer.Roughness, GBuffer.SpecularColor, Context, NoL, AreaLight);
		// }
        Lighting.Specular = (Falloff * NoL) * SpecularGGX; // defined on input
	}

	// FBxDFEnergyTerms EnergyTerms = ComputeGGXSpecEnergyTerms(GBuffer.Roughness, Context.NoV, GBuffer.SpecularColor);

	// Add energy presevation (i.e. attenuation of the specular layer onto the diffuse component
	//Lighting.Diffuse *= ComputeEnergyPreservation(EnergyTerms);

	// Add specular microfacet multiple scattering term (energy-conservation)
	//Lighting.Specular *= ComputeEnergyConservation(EnergyTerms);

	//Lighting.Transmission = 0;
	return Lighting.Diffuse + Lighting.Specular;
}

