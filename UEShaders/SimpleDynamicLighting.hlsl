float3 main(float NoL, float DistanceAttenuation, float AmbientOcclusion, float3 LightColor, float3 SimpleShading)
{
    float Attenuation = DistanceAttenuation * AmbientOcclusion;
    return (max(NoL, 0.0) * Attenuation) * (LightColor * SimpleShading);
}