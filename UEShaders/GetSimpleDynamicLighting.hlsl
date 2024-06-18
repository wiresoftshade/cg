//FSimpleDeferredLightData LightData;
/** 
 * Calculates lighting for a given position, normal, etc with a simple lighting model designed for speed. 
 * All lights rendered through this method are unshadowed point lights with no shadowing or light function or IES.
 * A cheap specular is used instead of the more correct area specular, no fresnel.
 */

float3 GetSimpleDynamicLighting(float3 LightColor, float3 SimpleShading, float NoL, float AmbientOcclusion)
{
	//float3 V = -CameraVector;
	//float3 N = WorldNormal;
	//float3 ToLight = LightData.Position - WorldPosition;
	float DistanceAttenuation = 1.0;
	
	//float DistanceSqr = dot( ToLight, ToLight );
	// float3 L = ToLight * rsqrt( DistanceSqr );
	//float NoL = saturate( dot( N, L ) );


	float3 OutLighting = 0.0;

	//const float3 LightColor = LightData.Color;


	// Apply SSAO to the direct lighting since we're not going to have any other shadowing
	float Attenuation = DistanceAttenuation * AmbientOcclusion;

	OutLighting += (NoL * Attenuation) * (LightColor * SimpleShading);


	return OutLighting;
}

