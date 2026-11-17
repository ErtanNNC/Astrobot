shader_type spatial;
// Greybox malzemesi: dünya koordinatında 1 m'lik ızgara çizgileri.
// Mesafeleri gözle ölçmeyi kolaylaştırır.

uniform vec4 base_color : source_color = vec4(0.7, 0.7, 0.72, 1.0);
uniform vec4 line_color : source_color = vec4(0.0, 0.0, 0.0, 0.25);
uniform float line_width = 0.03;

varying vec3 world_pos;
varying vec3 world_normal;

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float grid(vec2 p) {
	vec2 g = abs(fract(p - 0.5) - 0.5);
	vec2 w = fwidth(p) + line_width;
	vec2 l = 1.0 - smoothstep(vec2(0.0), w, g);
	return max(l.x, l.y);
}

void fragment() {
	vec3 n = abs(world_normal);
	float l;
	if (n.y > n.x && n.y > n.z) {
		l = grid(world_pos.xz);
	} else if (n.x > n.z) {
		l = grid(world_pos.zy);
	} else {
		l = grid(world_pos.xy);
	}
	ALBEDO = mix(base_color.rgb, line_color.rgb, l * line_color.a);
	ROUGHNESS = 0.85;
}
