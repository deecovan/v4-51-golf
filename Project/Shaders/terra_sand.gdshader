shader_type spatial;

uniform float height_scale = 2;
uniform sampler2D noise;
uniform sampler2D normalmap;
varying vec2 tex_position;

void vertex() {
	// Add Noise
	tex_position = VERTEX.xz / 3.0 + 0.5;
	float height = texture(noise, tex_position).x;
	VERTEX.y += height * height_scale - 0.5;
	// Add Waves
	VERTEX.y += cos(VERTEX.x) * sin(VERTEX.z) / (2.0 * PI);
	// Clamp Borders
	if ((VERTEX.z < -63.0 || VERTEX.z > 63.0) 
			|| (VERTEX.x < -63.0 || VERTEX.x > 63.0)) {
		VERTEX.y = 0.0;
	}
}

void fragment() {
	// Set Color
	ALBEDO = vec3(0.5, 0.3, 0.1 );
	// Add Normals
	NORMAL_MAP = texture(normalmap, tex_position).xyz;
}