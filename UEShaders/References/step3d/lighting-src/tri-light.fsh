//
// Trilight lighting fragment shader
//

varying	vec3 l;
varying vec3 n;

void main (void)
{
	const vec4	color0 = vec4 ( 0.5, 0.0, 0.0, 1.0 );
	const vec4	color1 = vec4 ( 0.5, 0.5, 0.0, 1.0 );
	const vec4	color2 = vec4 ( 0.5, 0.5, 0.5, 1.0 );

	vec3	n2   = normalize ( n );
	vec3	l2   = normalize ( l );
	vec4	diff = color0 * max ( dot ( n2, l2 ), 0.0 ) + color1 * ( 1.0 - abs ( dot ( n2, l2)) ) + color2 * max ( dot ( -n2, l2), 0.0 );

	gl_FragColor = diff;
}
