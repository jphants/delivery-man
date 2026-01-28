shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

uniform float contrast : hint_range(0.5, 3.0) = 1.8;
uniform float brightness : hint_range(-0.5, 0.5) = -0.1;
uniform float steps : hint_range(2.0, 8.0) = 4.0;
uniform float grain_strength : hint_range(0.0, 0.2) = 0.05;
uniform vec3 tint : source_color = vec3(0.9, 0.9, 1.0);

float rand(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
	// Leer la pantalla
	vec4 col = texture(screen_tex, SCREEN_UV);

	// Contraste duro noir
	col.rgb = (col.rgb - 0.5) * contrast + 0.5;

	// Brillo
	col.rgb += brightness;

	// Posterización comic
	col.rgb = floor(col.rgb * steps) / steps;

	// Grano cinematográfico
	float grain = rand(SCREEN_UV * TIME) - 0.5;
	col.rgb += grain * grain_strength;

	// Tinte frío mafia
	col.rgb *= tint;

	COLOR = col;
}
