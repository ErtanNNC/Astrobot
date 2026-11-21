shader_type spatial;
render_mode unshaded, cull_disabled;
// Lav yüzeyi: ağır ağır akan koyu kabuk parçaları, aralarında parlayan çatlaklar (telefona uygun, dokusuz).

uniform vec4 hot : source_color = vec4(1.0, 0.78, 0.2, 1.0);
uniform vec4 glow : source_color = vec4(1.0, 0.36, 0.05, 1.0);
uniform vec4 crust : source_color = vec4(0.32, 0.1, 0.06, 1.0);
uniform float cell = 2.2;          // kabuk parçası boyu (m)
uniform float flow = 0.12;         // akış hızı

varying vec3 wp;

vec2 hash2(vec2 p) {
	return fract(sin(vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)))) * 43758.5453);
}

void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	VERTEX.y += sin(wp.x * 0.5 + TIME * 0.8) * cos(wp.z * 0.45 + TIME * 0.6) * 0.05;
}

void fragment() {
	vec2 uv = wp.xz / cell + vec2(TIME * flow, TIME * flow * 0.6);
	vec2 g = floor(uv);
	vec2 f = fract(uv);
	float d1 = 9.0;
	float d2 = 9.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 o = vec2(float(x), float(y));
			vec2 h = hash2(g + o);
			h = 0.5 + 0.4 * sin(TIME * 0.5 + 6.2831 * h);
			float d = length(o + h - f);
			if (d < d1) { d2 = d1; d1 = d; } else if (d < d2) { d2 = d; }
		}
	}
	float edge = d2 - d1;                                   // 0 = çatlak, büyük = parçanın ortası
	float crack = 1.0 - smoothstep(0.03, 0.22, edge);
	float pulse = 0.85 + 0.15 * sin(TIME * 1.7 + wp.x * 0.6 + wp.z * 0.4);
	vec3 c = mix(crust.rgb, glow.rgb, smoothstep(0.0, 0.55, 1.0 - edge * 1.6) * 0.55);
	c = mix(c, hot.rgb, crack * pulse);
	ALBEDO = c;
}
