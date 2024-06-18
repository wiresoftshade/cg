const static float PI = 3.1415926535897932f;

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

// Relative error : < 0.4% over full
// Precise format : ~small float
// 1 ALU
float rcpFast( float x )
{
	int i = asint(x);
	i = 0x7EF311C2 - i;
	return asfloat(i);
}

// [ Chan 2018, "Material Advances in Call of Duty: WWII" ]
// It has been extended here to fade out retro reflectivity contribution from area light in order to avoid visual artefacts.
float3 Diffuse_Chan( float3 DiffuseColor, float a2, float NoV, float NoL, float VoH, float NoH, float RetroReflectivityWeight)
{
	// We saturate each input to avoid out of range negative values which would result in weird darkening at the edge of meshes (resulting from tangent space interpolation).
	NoV = saturate(NoV);
	NoL = saturate(NoL);
	VoH = saturate(VoH);
	NoH = saturate(NoH);

	// a2 = 2 / ( 1 + exp2( 18 * g )
	float g = saturate( (1.0 / 18.0) * log2( 2 * rcpFast(a2) - 1 ) );

	float F0 = VoH + Pow5( 1 - VoH );
	float FdV = 1 - 0.75 * Pow5( 1 - NoV );
	float FdL = 1 - 0.75 * Pow5( 1 - NoL );

	// Rough (F0) to smooth (FdV * FdL) response interpolation
	float Fd = lerp( F0, FdV * FdL, saturate( 2.2 * g - 0.5 ) );

	// Retro reflectivity contribution.
	float Fb = ( (34.5 * g - 59 ) * g + 24.5 ) * VoH * exp2( -max( 73.2 * g - 21.2, 8.9 ) * sqrtFast( NoH ) );
	// It fades out when lights become area lights in order to avoid visual artefacts.
	Fb *= RetroReflectivityWeight;
	
	return DiffuseColor * ( (1 / PI) * ( Fd + Fb ) );
}


