shader_type spatial;
render_mode specular_schlick_ggx;

uniform vec3 concrete_color : source_color = vec3(0.52, 0.52, 0.50);

uniform float roughness_base : hint_range(0.0, 1.0) = 0.95;
uniform float metallic_base : hint_range(0.0, 1.0) = 0.02;

uniform float scale = 6.0;
uniform float pore_density = 20.0;   // cantidad de puntos
uniform float pore_size = 0.25;      // tamaño del poro
uniform float pore_strength = 0.6;
uniform float normal_strength = 2.5;

/* --------- POROS UNIFORMES --------- */

float pores_uniform(vec2 uv) {
    vec2 grid = fract(uv * pore_density);
    float d = distance(grid, vec2(0.5));
    return smoothstep(pore_size, pore_size - 0.05, d);
}

/* --------- SHADER --------- */

void fragment() {
    vec2 uv = UV * scale;

    float pores = pores_uniform(uv);

    // Color limpio, solo poros
    vec3 color = concrete_color;
    color -= pores * 0.15;

    ALBEDO = color;

    // Rugosidad solo afectada por poros
    ROUGHNESS = clamp(
        roughness_base + pores * 0.2,
        0.85,
        1.0
    );

    METALLIC = metallic_base;

    // Normal map poroso
    float h = -pores * pore_strength;

    vec3 normal_map = vec3(
        dFdx(h),
        dFdy(h),
        1.0 / normal_strength
    );

    NORMAL = normalize(normal_map);
}
