float3 main(float N, float V, float L, float Roughness, float3 Diffuse_Lambert, float3 SpecularColor)
{
	float3 H = normalize(V + L);
	float NoH = saturate( dot(N, H) );
	float RR = Roughness*Roughness;
	float a2 = RR*RR;
	
	// GGX / Trowbridge-Reitz
	// [Walter et al. 2007, "Microfacet models for refraction through rough surfaces"]
	// Generalized microfacet specular
	float d = ( NoH * a2 - NoH ) * NoH + 1;	// 2 mad
	float D = a2 / ( PI*d*d ); // 4 mul, 1 rcp

	float Vis = 0.25;
	float3 F = SpecularColor;

	return Diffuse_Lambert + (D * Vis) * F;
}