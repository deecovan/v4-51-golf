shader_type spatial;

uniform float height_scale = 2;
uniform sampler2D noise;
uniform sampler2D normalmap;
varying vec2 tex_position;

void vertex() {
	tex_position = VERTEX.xz / 3.0 + 0.5;
	float height = texture(noise, tex_position).x;
	VERTEX.y += height * height_scale - 0.5;
	if (VERTEX.z > 63.0) {
		VERTEX.y = 0.0;
	}
	// VERTEX.y += cos(VERTEX.x) * sin(VERTEX.z) / (2.0 * PI);
}

void fragment() {
	NORMAL_MAP = texture(normalmap, tex_position).xyz;
	ALBEDO = vec3(0.5, 0.3, 0.1 );
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
