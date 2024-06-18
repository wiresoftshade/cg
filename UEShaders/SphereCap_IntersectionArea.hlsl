// SphereCap_IntersectionArea

float main(float d, float r0, float r1)
{
    #if !defined(include_hlsl)
    #define include_hlsl 1

    #define PI 3.141592653589793238

    #endif

    float div1=cos(d)-(cos(r0)*cos(r1));
    div1/=sin(r0)*sin(r1);

    float div2=((-1)*cos(r1))+(cos(d)*cos(r0));
    div2/=sin(d)*sin(r0);

    float div3=((-1)*cos(r0))+(cos(d)*cos(r1));
    div3/=sin(d)*sin(r1);

    float term=(2*PI)-(2*PI*cos(r0));
    term-=2*PI*cos(r1);
    term-=2*acos(div1);
    term+=2*cos(r0)*acos(div2);
    term+=2*cos(r1)*acos(div3);

    return term;
}