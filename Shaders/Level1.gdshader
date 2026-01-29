shader_type canvas_item;

// Uniform requerido para acceder a la pantalla
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;

uniform float saturation : hint_range(0.0, 2.0) = 1.6;
uniform float contrast : hint_range(0.0, 2.0) = 1.3;
uniform float gamma : hint_range(0.1, 3.0) = 1.0;
uniform float brightness : hint_range(0.0, 1.0) = 0.0;
uniform float outline_strength : hint_range(0.0, 1.0) = 0.5;
uniform float light_threshold : hint_range(0.0, 1.0) = 0.5; // Para delimitar luces

vec3 rgb2gray(vec3 color){
    return vec3(dot(color, vec3(0.299,0.587,0.114)));
}

// Función de toon shading
vec3 toon_shade(vec3 color, float threshold){
    // Convertimos a gris para determinar luz
    float lum = dot(color, vec3(0.299,0.587,0.114));
    if(lum > threshold){
        return vec3(1.0); // Luz brillante
    } else {
        return vec3(0.0); // Sombra
    }
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Obtener color del fondo
    vec4 col = texture(SCREEN_TEXTURE, uv);

    // Saturación
    vec3 grey = rgb2gray(col.rgb);
    col.rgb = mix(grey, col.rgb, saturation);

    // Contraste
    col.rgb = ((col.rgb - 0.5) * contrast + 0.5);

    // Gamma y brillo
    col.rgb = pow(col.rgb, vec3(1.0 / gamma));
    col.rgb += brightness;

    // --- Outline más marcado usando Sobel simplificado ---
    vec2 offset = vec2(1.0 / 512.0, 1.0 / 512.0);
    float edge = 0.0;
    edge += length(texture(SCREEN_TEXTURE, uv + vec2(-offset.x, 0)).rgb - col.rgb);
    edge += length(texture(SCREEN_TEXTURE, uv + vec2(offset.x, 0)).rgb - col.rgb);
    edge += length(texture(SCREEN_TEXTURE, uv + vec2(0, -offset.y)).rgb - col.rgb);
    edge += length(texture(SCREEN_TEXTURE, uv + vec2(0, offset.y)).rgb - col.rgb);
    edge = clamp(edge * 10.0, 0.0, 1.0); // Multiplicador mayor para bordes más visibles

    // Aplicar toon shading a luces
    col.rgb = mix(toon_shade(col.rgb, light_threshold), col.rgb, 1.0 - edge * outline_strength);

    // Mantener transparencia
    COLOR = vec4(col.rgb, col.a);
}
