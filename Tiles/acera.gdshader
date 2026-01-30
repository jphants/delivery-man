shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec3 base_color : source_color = vec3(0.60, 0.60, 0.58);

uniform float roughness_base : hint_range(0.0, 1.0) = 0.9;
uniform float metallic_base : hint_range(0.0, 1.0) = 0.02;

uniform float scale = 3.0;
uniform float pore_scale = 18.0;
uniform float pore_strength = 0.25;
uniform float wear_strength = 0.15;
uniform float normal_strength = 1.5;

/* ------------ NOISE ------------ */

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
	for (int i = 0; i < 3; i++) {
		v += a * noise(p);
		p *= 2.0;
		a *= 0.5;
	}
	return v;
}

/* ------------ SHADER ------------ */

void fragment() {
	vec2 uv = UV * scale;

	// Desgaste general
	float wear = fbm(uv * 0.8);

	// Poros finos
	float pores = noise(uv * pore_scale);
	pores = smoothstep(0.55, 0.65, pores);

	// Color base con manchas
	vec3 color = base_color;
	color -= pores * 0.05;
	color += (wear - 0.5) * wear_strength;

	ALBEDO = color;

	// Rugosidad más pareja (vereda pisada)
	ROUGHNESS = clamp(
		roughness_base + pores * 0.05 + wear * 0.08,
		0.85,
		0.98
	);

	METALLIC = metallic_base;

	// Normal suave (no tan agresiva)
	float h = wear * 0.4 - pores * pore_strength;

	vec3 normal_map = vec3(
		dFdx(h),
		dFdy(h),
		1.0 / normal_strength
	);

	NORMAL = normalize(normal_map);
}
