shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

// Intensidad general del sepia
uniform float sepia_amount : hint_range(0.0, 1.0) = 0.7;

// A partir de qué luminancia se conserva el color
uniform float highlight_preserve : hint_range(0.0, 1.0) = 0.6;

// Qué tan fuerte se mantiene el color en luces
uniform float highlight_strength : hint_range(0.0, 1.0) = 0.8;

// Contraste y brillo finos
uniform float contrast : hint_range(0.5, 2.0) = 1.1;
uniform float brightness : hint_range(-0.3, 0.3) = 0.05;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 col = texture(SCREEN_TEXTURE, uv);

	// Luminancia perceptual
	float lum = dot(col.rgb, vec3(0.299, 0.587, 0.114));

	// Sepia clásico
	vec3 sepia;
	sepia.r = dot(col.rgb, vec3(0.393, 0.769, 0.189));
	sepia.g = dot(col.rgb, vec3(0.349, 0.686, 0.168));
	sepia.b = dot(col.rgb, vec3(0.272, 0.534, 0.131));

	// Más sepia en sombras, menos en luces
	float sepia_mix = sepia_amount * (1.0 - smoothstep(highlight_preserve, 1.0, lum));

	// Mezclar original ↔ sepia
	vec3 color_mixed = mix(col.rgb, sepia, sepia_mix);

	// Recuperar color en highlights
	color_mixed = mix(color_mixed, col.rgb, smoothstep(highlight_preserve, 1.0, lum) * highlight_strength);

	// Contraste y brillo finales
	color_mixed = ((color_mixed - 0.5) * contrast) + 0.5;
	color_mixed += brightness;

	COLOR = vec4(color_mixed, col.a);
}
