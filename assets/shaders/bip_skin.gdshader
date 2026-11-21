shader_type spatial;
// Bip'in kostüm (renk) gölgelendiricisi: dokunun boyalı (doygun) yerlerinin tonunu kaydırır,
// gri metal ve siyah gözler aynı kalır. Taşınan yetenek 'tint' ile hafifçe boyar.
// Kostümler: GameState.SKINS. Bkz. docs/features/kostum/design.md

uniform sampler2D albedo_tex : source_color, filter_linear_mipmap;
uniform vec4 tint : source_color = vec4(1.0);
uniform float hue_shift = 0.0;     // 0..1 tur
uniform float sat_mul = 1.0;
uniform float val_mul = 1.0;
uniform vec3 glow = vec3(0.0);     // altın kostümde hafif parıltı

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec3 col = texture(albedo_tex, UV).rgb;
	vec3 hsv = rgb2hsv(col);
	float paint = smoothstep(0.25, 0.45, hsv.y);      // yalnızca boyalı yerler
	vec3 shifted = hsv2rgb(vec3(fract(hsv.x + hue_shift), clamp(hsv.y * sat_mul, 0.0, 1.0), clamp(hsv.z * val_mul, 0.0, 1.0)));
	col = mix(col, shifted, paint);
	ALBEDO = col * tint.rgb;
	EMISSION = glow * paint;
	ROUGHNESS = 0.75;
}
