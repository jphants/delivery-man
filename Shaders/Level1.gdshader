shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;
uniform float saturation : hint_range(0.0, 2.0) = 1.0;

void fragment() {
    // Captura lo que hay detrás del ColorRect
    vec4 screen_color = texture(screen_tex, SCREEN_UV);

    // Luminancia perceptual
    float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));

    // Aplicar saturación
    vec3 final_color = mix(vec3(gray), screen_color.rgb, saturation);

    COLOR = vec4(final_color, screen_color.a);
}
