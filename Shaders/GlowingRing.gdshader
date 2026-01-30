shader_type spatial;

uniform vec4 glow_color : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform float glow_strength : hint_range(0.0, 10.0) = 2.0;

void fragment() {
    ALBEDO = glow_color.rgb;
    EMISSION = glow_color.rgb * glow_strength;
}
