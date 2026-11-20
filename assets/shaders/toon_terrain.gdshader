shader_type spatial;
// Seviye zemini: üst yüzey çimen (hafif desenli), yan yüzeyler katmanlı toprak.
// Quaternius "Ultimate Platformer Pack" modellerinin görünüşüne uyacak şekilde.
// Ölçüm kolaylığı için üst yüzeyde çok silik 1 m ızgara var (grid_alpha = 0 kapatır).

uniform vec4 top_color : source_color = vec4(0.55, 0.82, 0.25, 1.0);
uniform vec4 top_color2 : source_color = vec4(0.47, 0.74, 0.22, 1.0);
uniform vec4 side_a : source_color = vec4(0.93, 0.66, 0.42, 1.0);
uniform vec4 side_b : source_color = vec4(0.84, 0.55, 0.33, 1.0);
uniform float band_height = 0.35;
uniform float grid_alpha = 0.07;
uniform float top_threshold = 0.7;
// El boyaması dokular (freegameassets.com "Painterly Fantasy Textures", CC0). Yoksa eski renkli görünüm.
uniform bool use_side_tex = false;
uniform bool use_top_tex = false;
uniform sampler2D side_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D top_tex : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float tex_size = 3.0;      // m, doku bu kadar uzunlukta bir kez tekrar eder
uniform float tex_tint = 0.12;     // temanın rengine ne kadar yaklaşsın
uniform float tex_gain = 1.0;      // koyu dokuları aydınlatmak için (fabrika çeliği)
// Kanyon kaya katmanları: yan yüzey dünya yüksekliğine göre renk şeritlerine boyanır (tek kutuda katmanlı kaya)
uniform bool strata = false;
uniform float strata_height = 2.6;
uniform vec4 strata_a : source_color = vec4(0.93, 0.52, 0.32, 1.0);
uniform vec4 strata_b : source_color = vec4(0.98, 0.80, 0.55, 1.0);
uniform vec4 strata_c : source_color = vec4(0.78, 0.36, 0.25, 1.0);
uniform vec4 strata_d : source_color = vec4(0.95, 0.66, 0.42, 1.0);

varying vec3 wp;
varying vec3 wn;

void vertex() {
	wp = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	wn = normalize((MODEL_MATRIX * vec4(NORMAL, 0.0)).xyz);
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float vnoise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1, 0)), f.x),
			   mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), f.x), f.y);
}

float grid(vec2 p) {
	vec2 g = abs(fract(p - 0.5) - 0.5);
	vec2 w = fwidth(p) * 1.2;
	vec2 l = 1.0 - smoothstep(vec2(0.0), w, g);
	return max(l.x, l.y);
}

void fragment() {
	vec3 col;
	if (wn.y > top_threshold && use_top_tex) {
		col = texture(top_tex, wp.xz / tex_size).rgb;
		col = mix(col, col * top_color.rgb * 1.6, tex_tint) * tex_gain;
		ROUGHNESS = 0.9;
	} else if (wn.y <= top_threshold && use_side_tex) {
		vec2 uv = abs(wn.x) > abs(wn.z) ? wp.zy : wp.xy;
		col = texture(side_tex, uv / tex_size).rgb;
		if (wn.y < -0.5) {
			col = texture(side_tex, wp.xz / tex_size).rgb * 0.75;
		}
		col = mix(col, col * side_a.rgb * 1.5, tex_tint) * tex_gain;
		if (strata) {
			float y = wp.y / strata_height + vnoise(wp.xz * 0.35 + wp.zx * 0.11) * 0.45;
			float k = mod(floor(y), 4.0);
			vec3 sc = k < 0.5 ? strata_a.rgb : (k < 1.5 ? strata_b.rgb : (k < 2.5 ? strata_c.rgb : strata_d.rgb));
			float lum = dot(col, vec3(0.3, 0.55, 0.15));
			col = sc * (0.55 + lum * 0.9);
			// şerit sınırlarında ince koyu çizgi
			col *= 1.0 - 0.22 * (1.0 - smoothstep(0.0, 0.06, fract(y))) ;
		}
		ROUGHNESS = 0.95;
	} else if (wn.y > top_threshold) {
		float n = vnoise(wp.xz * 0.6) * 0.6 + vnoise(wp.xz * 2.3) * 0.4;
		col = mix(top_color.rgb, top_color2.rgb, smoothstep(0.35, 0.75, n));
		col = mix(col, col * 0.7, grid(wp.xz) * grid_alpha / 0.07 * 0.25);
		ROUGHNESS = 0.9;
	} else if (wn.y < -0.5) {
		col = side_b.rgb * 0.8;
		ROUGHNESS = 0.95;
	} else {
		float y = wp.y + vnoise(wp.xz * 1.3 + wp.zx) * 0.06;
		float band = step(0.5, fract(y / band_height));
		col = mix(side_a.rgb, side_b.rgb, band);
		ROUGHNESS = 0.95;
	}
	ALBEDO = col;
}
