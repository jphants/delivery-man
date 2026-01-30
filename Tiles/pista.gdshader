shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec3 concrete_color : source_color = vec3(0.52, 0.52, 0.50);

uniform float roughness_base : hint_range(0.0, 1.0) = 0.95;
uniform float metallic_base : hint_range(0.0, 1.0) = 0.02;

uniform float scale = 6.0;
uniform float pore_scale = 25.0;
uniform float pore_strength = 0.6;
uniform float normal_strength = 2.5;

/* ---------------- NOISE ---------------- */

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

/* ---------------- SHADER ---------------- */

void fragment() {
	vec2 uv = UV * scale;

	// Ruido base
	float base_noise = fbm(uv);

	// Poros (ruido de alta frecuencia + threshold)
	float pores = noise(uv * pore_scale);
	pores = smoothstep(0.45, 0.6, pores);

	// Color con manchas
	vec3 color = concrete_color;
	color -= pores * 0.12;
	color += (base_noise - 0.5) * 0.08;

	ALBEDO = color;

	// Rugosidad extrema con variación
	ROUGHNESS = clamp(
		roughness_base + pores * 0.2 + base_noise * 0.1,
		0.85,
		1.0
	);

	METALLIC = metallic_base;

	// Normal porosa (clave del efecto)
	float h = base_noise - pores * pore_strength;

	vec3 normal_map = vec3(
		dFdx(h),
		dFdy(h),
		1.0 / normal_strength
	);

	NORMAL = normalize(normal_map);
}
