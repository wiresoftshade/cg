// [Burley 2012, "Physically-Based Shading at Disney"]


float3 main(float3 DiffuseColor,float Roughness,float3 N,float3 V,float3 L)
{
    float NoL = dot(N, L);
    float NoV = dot(N,V);
    float VoL = dot(V, L);
    float InvLenH = rsqrt( 2 + 2 *  VoL );
    float NoH = saturate( (  NoL +  NoV ) * InvLenH );
    float VoH = saturate( InvLenH + InvLenH *  VoL );
    NoL = saturate( NoL );
    NoV = saturate( abs( NoV ) + 1e-5 );

    float FD90 = 0.5 + 2 * VoH * VoH * Roughness;
    float FdV = 1 + (FD90 - 1) * Pow5( 1 - NoV ); // pow5() is work in UE custom node
    float FdL = 1 + (FD90 - 1) * Pow5( 1 - NoL );
    return DiffuseColor * ( (1 / PI) * FdV * FdL );
}