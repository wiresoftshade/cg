float3 main(float NoL, float DistanceAttenuation, float AmbientOcclusion, float3 LightColor, float3 DiffuseShading, float3 SpecularShading)
{    
    float Attenuation = DistanceAttenuation * AmbientOcclusion;
    return (max(NoL, 0.0) * Attenuation) * ((DiffuseShading + SpecularShading) * LightColor);    
}

