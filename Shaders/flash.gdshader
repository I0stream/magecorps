shader_type spatial;

uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red flash
uniform float flash_intensity = 0.0; // 0 = no flash, 1 = full flash

void fragment() {
    vec3 base_color = vec3(1.0); // Base white color
    vec3 flash = flash_color.rgb * flash_intensity;
    ALBEDO = base_color + flash; // Combine base color and flash
}
