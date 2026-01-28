shader_type spatial;
render_mode unshaded;

uniform vec4 neon_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float intensity = 3.0;
uniform float pulse_speed = 2.5;

void fragment() {
    float pulse = 0.8 + 0.2 * sin(TIME * pulse_speed);

    // Color base del mesh
    vec3 base_color = COLOR.rgb;

    // Mezcla controlada (mantiene el tono)
    vec3 final_color = base_color * neon_color.rgb;

    ALBEDO = final_color * intensity * pulse;
}
