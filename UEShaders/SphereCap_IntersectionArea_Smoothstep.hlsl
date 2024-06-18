// SphereCap_IntersectionArea_Smoothstep

float main(float d, float r0, float r1)
{
    #if !defined(include_hlsl)
    #define include_hlsl 1

    #define PI 3.141592653589793238

    #endif

    float a = ((2*PI)-(2*PI*cos(min(r1,r0))));
    a*=smoothstep(0,1,1-(d-length(r0-r1))/(r0+r1-(length(r0-r1))));

    return a;
}