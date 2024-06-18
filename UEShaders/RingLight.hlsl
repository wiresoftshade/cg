// Ring indirect reflection lighting

float remapValueRange( float value, float  iL, float iH, float tL, float tH)
{    
    //return ((value-iL)/(iH-iL) * (tH-tL)) + tL;   
    return (value+1); // if
}


// L, N - normalized
float3 main(float ringRadius, float3 L, float3 N, float3 LocalPos, float3 LightColor, float3 RingAlbedo)
{
    float2 equator = normalize(LocalPos.xy);
    float2 ringPos = ringRadius * equator;
    float3 rL = -normalize(N - float3(ringPos, 0.0));
    float3 sideVector = float3(0.0, 0.0, sign(L.z));
    float Shading = max(0.0, dot(N, rL)) * max(0.0, (rL, -sideVector));
    float RingIllum = dot(sideVector, L);
    // float BackShadow = dot(equator, normalize(L.xy));
    //       BackShadow = remapValueRange(BackShadow, -1.0, 1.0, 0.0, 2.0);
    // becouse remap inputs is fixed then: 
    float BackShadow = 1.0 + dot(equator, normalize(L.xy));
    float DistanceSquare = length(rL) + 1.0; 
    DistanceSquare *= DistanceSquare;
    
    return Shading * RingIllum * BackShadow * RingAlbedo / DistanceSquare;
}