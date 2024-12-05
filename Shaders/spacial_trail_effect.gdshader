shader_type spatial;

render_mode unshaded, blend_add, world_vertex_coords, cull_disabled;

uniform sampler2D tex;

void vertex() {
	// Mixing the world matrix components to calculate vertex position
	vec3 a = mix(MODEL_MATRIX[3].xyz, MODEL_MATRIX[2].xyz, UV.y);
	vec3 b = mix(MODEL_MATRIX[0].xyz, MODEL_MATRIX[1].xyz, UV.y);
	VERTEX = mix(a, b, UV.x);

	// Adjusting UV coordinates
	UV.x = (INSTANCE_CUSTOM.w - 1.0 - UV.x) / INSTANCE_CUSTOM.z;
}

void fragment() {
	// Sampling the texture
	vec4 T = texture(tex, UV);
	ALBEDO = T.rgb;
	ALPHA = T.a;
}
