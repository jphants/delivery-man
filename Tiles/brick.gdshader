shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec3 brick_color : source_color = vec3(0.65, 0.32, 0.22);
uniform vec3 mortar_color : source_color = vec3(0.78, 0.78, 0.75);

uniform float roughness_brick : hint_range(0.0, 1.0) = 0.85;
uniform float roughness_mortar : hint_range(0.0, 1.0) = 0.95;
uniform float metallic_base : hint_range(0.0, 1.0) = 0.02;

uniform vec2 brick_repeat = vec2(6.0, 3.0); // cuántos ladrillos
uniform float mortar_thickness = 0.08;

uniform float color_variation = 0.15;
uniform float height_strength = 0.6;
uniform float normal_strength = 2.0;

/* ---------- UTILS ---------- */

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

/* ---------- SHADER ---------- */

void fragment() {
	vec2 uv = UV * brick_repeat;

	// Offset por fila (patrón real)
	if (int(floor(uv.y)) % 2 == 1) {
		uv.x += 0.5;
	}

	vec2 cell = fract(uv);
	vec2 brick_id = floor(uv);

	/* ----- MÁSCARA DE MORTERO (CORRECTA) ----- */
	float mx = smoothstep(0.0, mortar_thickness, cell.x)
			 + smoothstep(1.0 - mortar_thickness, 1.0, cell.x);
	float my = smoothstep(0.0, mortar_thickness, cell.y)
			 + smoothstep(1.0 - mortar_thickness, 1.0, cell.y);

	float mortar = clamp(mx + my, 0.0, 1.0);

	/* ----- COLOR ----- */
	float rand = hash(brick_id);
	vec3 brick_col = brick_color + (rand - 0.5) * color_variation;

	ALBEDO = mix(brick_col, mortar_color, mortar);

	/* ----- MATERIAL ----- */
	ROUGHNESS = mix(roughness_brick, roughness_mortar, mortar);
	METALLIC = metallic_base;

	/* ----- RELIEVE ----- */
	float height = mix(height_strength, -0.15, mortar);

	vec3 normal_map = vec3(
		dFdx(height),
		dFdy(height),
		1.0 / normal_strength
	);

	NORMAL = normalize(normal_map);
}
