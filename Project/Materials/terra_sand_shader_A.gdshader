shader_type spatial;

uniform float height_scale = 1;
uniform sampler2D noise;
uniform sampler2D normalmap;
varying vec2 tex_position;

void vertex() {
	// Add Noise
	//tex_position = VERTEX.xz / 30.0 + 0.5;
	//float height = texture(noise, tex_position).x;
	//VERTEX.y += height * height_scale;
	// Add Waves
	// VERTEX.y += (cos(VERTEX.x*PI) * sin(VERTEX.z*PI))/(PI*PI);
}

void fragment() {
	// Set Color
	ALBEDO = vec3(0.45, 0.24, 0.05);
	// Add Normals
	NORMAL_MAP = texture(normalmap, tex_position).xyz;
}