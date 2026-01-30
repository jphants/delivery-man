shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec3 grass_color_dark  : source_color = vec3(0.18, 0.35, 0.12);
uniform vec3 grass_color_light : source_color = vec3(0.35, 0.55, 0.22);

uniform float roughness_base : hint_range(0.0, 1.0) = 0.85;
uniform float metallic_base : hint_range(0.0, 1.0) = 0.0;

uniform float scale = 6.0;
uniform float detail_scale = 25.0;
uniform float color_variation = 0.6;
uniform float normal_strength = 1.5;

/* -------- NOISE -------- */

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);

	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) +
		   (c - a) * u.y * (1.0 - u.x) +
		   (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

/* -------- SHADER -------- */

void fragment() {
	vec2 uv = UV * scale;

	// Variación grande (manchas)
	float base = fbm(uv * 0.6);

	// Detalle fino (hojas)
	float detail = noise(uv * detail_scale);

	// Mezcla de colores
	vec3 grass_color = mix(
		grass_color_dark,
		grass_color_light,
		base
	);

	grass_color += (detail - 0.5) * color_variation * 0.2;

	ALBEDO = grass_color;

	// Pasto = difuso
	ROUGHNESS = clamp(
		roughness_base + detail * 0.1,
		0.75,
		0.95
	);

	METALLIC = metallic_base;

	// Normal suave (no exagerar)
	float h = base * 0.3 + detail * 0.15;

	vec3 normal_map = vec3(
		dFdx(h),
		dFdy(h),
		1.0 / normal_strength
	);

	NORMAL = normalize(normal_map);
}
