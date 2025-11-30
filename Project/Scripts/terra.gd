extends Node3D
	## Apply Shader logic to CollisionShape3D.map_data
	#tex_position = VERTEX.xz / 3.0 + 0.5;
	#float height = texture(noise, tex_position).x;
	#VERTEX.y += height * height_scale;
	#if (VERTEX.z > 63.0) {
		#VERTEX.y = 0.0;
	#}
	
@export var heightmap_texture: NoiseTexture2D # Or any ImageTexture
@export var collision_shape_node: CollisionShape3D

func _ready():
	## Get Object(NoiseTexture2D) noise from shader parameters
	var noise = $MeshInstance3D.get_surface_override_material(0).get_shader_parameter("noise")
	var image = noise.get_image()
	if image:
		## Ensure the image is in the correct format
		image.convert(Image.FORMAT_RF)
		## Create a new HeightmapShape3D
		var heightmap_shape = HeightMapShape3D.new()
		## Assign dimensions
		heightmap_shape.map_width = image.get_width()
		heightmap_shape.map_depth = image.get_height()
		## Assign the data (already in PackedFloat32Array format)
		heightmap_shape.map_data = image.get_data().to_float32_array()
		## Assign the shape to the CollisionShape3D node
		$StaticBody3D/CollisionShape3D.shape = heightmap_shape
		
