// [Gotanda 2012, "Beyond a Simple Physically Based Blinn-Phong Model in Real-Time"]

float3 main(float3 N, float3 L, float3 V, float3 DiffuseColor, float Roughness,)
{
	float NoL = dot(N, L);
	float NoV = dot(N,V);
	float VoL = dot(V, L);
	float InvLenH = rsqrt( 2 + 2 *  VoL );
	float NoH = saturate( (  NoL +  NoV ) * InvLenH );
	float VoH = saturate( InvLenH + InvLenH *  VoL );
    NoL = saturate( NoL );
    NoV = saturate( abs( NoV ) + 1e-5 );

	
    float a = Roughness * Roughness;
	float s = ( 1.29 + 0.5 * a );
	float s2 = s * s;
	VoL = 2.0 * VoH * VoH - 1.0;		// double angle identity
	float Cosri = VoL - NoV * NoL;
	float C1 = 1.0 - 0.5 * s2 / (s2 + 0.33);
	float C2 = 0.45 * s2 / (s2 + 0.09) * Cosri * ( Cosri >= 0.0 ? rcp( max( NoL, NoV ) ) : 1.0 );

	return DiffuseColor / PI * ( C1 + C2 ) * ( 1.0 + Roughness * 0.5 );
}