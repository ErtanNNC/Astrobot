shader_type spatial;
// Yürünen zeminlerin üstü (zemin boyuna ölçeklenen 1 m kalın tek parça örtü): dikiş yok, dünya uzayında el boyaması
// doku + büyük ölçekli renk dalgalanması; kenarlardan aşağı sarkan dalgalı "saçak" (çimen/kar örtüsü).
// Saçağın altı çizilmez: alttaki gövdenin kaya/toprak dokusu görünür. Temalar: scripts/level/kit_batch.gd

uniform sampler2D top_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform vec4 tint_a : source_color = vec4(0.42, 0.78, 0.25, 1.0);
uniform vec4 tint_b : source_color = vec4(0.56, 0.86, 0.30, 1.0);
uniform vec4 fringe : source_color = vec4(0.34, 0.68, 0.22, 1.0);
uniform float tex_size = 4.0;        // m
uniform float tex_mix = 0.3;         // dokunun kendi renginden ne kadar
uniform float fringe_depth = 0.34;   // m
uniform float fringe_wave = 0.5;     // 0 düz şerit, 1 derin dalga
uniform float rough = 0.9;
uniform float avg_lum = 0.5;      // dokunun ortalama parlaklığı (koyu dokular zemini karartmasın)

varying vec3 wp;
varying vec3 wn;
varying float ly;

float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float vnoise(vec2 p) {
	vec2 i = floor(p); vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x), mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

void vertex() {
	ly = VERTEX.y;
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
	if (NORMAL.y > 0.3) {
		NORMAL = vec3(0.0, 1.0, 0.0);   // pah kırıklarını düzle: karo çizgileri görünmesin
	}
}

void fragment() {
	vec3 col;
	if (wn.y > 0.3) {
		vec3 tex = texture(top_tex, wp.xz / tex_size).rgb;
		float n = vnoise(wp.xz * 0.22) * 0.65 + vnoise(wp.xz * 0.9 + 7.3) * 0.35;
		vec3 base = mix(tint_a.rgb, tint_b.rgb, smoothstep(0.3, 0.7, n));
		float lum = dot(tex, vec3(0.3, 0.55, 0.15));
		col = base * (0.62 + lum * 0.62 / max(avg_lum, 0.05) * 0.5);
		col = mix(col, tex, tex_mix);
	} else if (wn.y < -0.5) {
		discard;
	} else {
		float h = 0.5 - ly;   // birim kutunun üstünden aşağı (m)
		float u = abs(wn.x) > abs(wn.z) ? wp.z : wp.x;
		float sc = abs(sin(u * 2.6)) * 0.6 + abs(sin(u * 5.9 + 1.7)) * 0.4;   // tarak gibi dalga
		float edge = fringe_depth * (1.0 - fringe_wave * 0.65 * sc);
		if (h > edge) {
			discard;
		}
		col = fringe.rgb * (0.82 + 0.18 * (1.0 - h / edge));
	}
	ALBEDO = col;
	ROUGHNESS = rough;
	SPECULAR = 0.2;
}
