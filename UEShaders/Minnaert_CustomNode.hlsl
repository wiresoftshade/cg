//
// Minnaert lighting model fragment shader
//

float3 main(float3 NoL, float3 NoV, float3 DiffuseColor, float k)
{
	//	k = 0.8 for example

	float d1 = pow ( max ( NoL, 0.0 ), 1.0 + k );
	//becouse artifact edit this: float d2 = pow ( 1.0 - NoV, 1.0 - k );
	// maybe we use different View(V) direction for NoV(dot product N, V)
	float d2 = pow ( NoV, 1.0 - k );

	return DiffuseColor * (d1 * d2);
}
