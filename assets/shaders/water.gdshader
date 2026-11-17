shader_type spatial;
render_mode cull_disabled;
// Basit, telefona uygun su: dalgalanan yüzey + kenarda açılan renk.

uniform vec4 deep : source_color = vec4(0.12, 0.45, 0.8, 1.0);
uniform vec4 shallow : source_color = vec4(0.35, 0.78, 0.95, 1.0);
uniform float wave_height = 0.25;
uniform float wave_speed = 0.6;

varying vec3 wp;

void vertex() {
	vec3 p = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float t = TIME * wave_speed;
	VERTEX.y += (sin(p.x * 0.35 + t) + cos(p.z * 0.3 + t * 1.3)) * wave_height;
	wp = p;
}

void fragment() {
	float t = TIME * 0.3;
	float ripple = sin(wp.x * 1.4 + t * 3.0) * cos(wp.z * 1.2 - t * 2.0);
	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), 3.0);
	vec3 c = mix(deep.rgb, shallow.rgb, 0.35 + 0.15 * ripple);
	ALBEDO = mix(c, vec3(0.85, 0.95, 1.0), fres * 0.5);
	ROUGHNESS = 0.15;
	SPECULAR = 0.6;
}
