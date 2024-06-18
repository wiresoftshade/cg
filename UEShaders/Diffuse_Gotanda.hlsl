// [Gotanda 2014, "Designing Reflectance Models for New Consoles"]

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
	float a2 = a * a;
	float F0 = 0.04;
	 VoL = 2 * VoH * VoH - 1;		// double angle identity
	float Cosri = VoL - NoV * NoL;
	float a2_13 = a2 + 1.36053;
	float Fr = ( 1 - ( 0.542026*a2 + 0.303573*a ) / a2_13 ) * ( 1 - pow( 1 - NoV, 5 - 4*a2 ) / a2_13 ) * ( ( -0.733996*a2*a + 1.50912*a2 - 1.16402*a ) * pow( 1 - NoV, 1 + rcp(39*a2*a2+1) ) + 1 );
	//float Fr = ( 1 - 0.36 * a ) * ( 1 - pow( 1 - NoV, 5 - 4*a2 ) / a2_13 ) * ( -2.5 * Roughness * ( 1 - NoV ) + 1 );
	float Lm = ( max( 1 - 2*a, 0 ) * ( 1 - Pow5( 1 - NoL ) ) + min( 2*a, 1 ) ) * ( 1 - 0.5*a * (NoL - 1) ) * NoL;
	float Vd = ( a2 / ( (a2 + 0.09) * (1.31072 + 0.995584 * NoV) ) ) * ( 1 - pow( 1 - NoL, ( 1 - 0.3726732 * NoV * NoV ) / ( 0.188566 + 0.38841 * NoV ) ) );
	float Bp = Cosri < 0 ? 1.4 * NoV * NoL * Cosri : Cosri;
	float Lr = (21.0 / 20.0) * (1 - F0) * ( Fr * Lm + Vd + Bp );
	return DiffuseColor / PI * Lr;
}