@tool
extends MeshInstance3D

@export_range(20,40,1) var terrain_size = 100
@export_range(1,100,1) var resolution = 30
const center_offset = 0.5
@export var terrain_max_height = 5
@export var noise_offset = 0.5
@export var create_collision = false
@export var remove_collision = false

var min_height = 0
var max_height = 1

func _ready() -> void:
	generate_terrain()
	
func generate_terrain() -> void:
	var array_mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = 0.1
	surface_tool.begin(mesh.PRIMITIVE_TRIANGLES)
	
	for z in resolution + 1:
		for x in resolution + 1:
			var percent = Vector2(x,z) / resolution
			var point = Vector3(
				percent.x-center_offset, 
				0, percent.y-center_offset)
			var vertex = point * terrain_size
			vertex.y = noise.get_noise_2d(
				vertex.x * noise_offset,
				vertex.y * noise_offset) * terrain_max_height
			var uv = Vector2()
			uv.x = percent.x
			uv.y = percent.y
			surface_tool.set_uv(uv)
			surface_tool.add_vertex(vertex)
	
	var vrt = 0
	for z in resolution:
		for x in resolution:
			surface_tool.add_index(vrt + 0)
			surface_tool.add_index(vrt + 1)
			surface_tool.add_index(vrt + resolution + 1)
			surface_tool.add_index(vrt + resolution + 1)
			surface_tool.add_index(vrt + 1)
			surface_tool.add_index(vrt + resolution + 2)
			vrt += 1
		vrt += 1
	surface_tool.generate_normals()
	array_mesh = surface_tool.commit()
	
	mesh = array_mesh
	update_shader()
	
func update_shader() -> void:
	var material = get_active_material(0)
	if material != null:
		material.set_shader_parameter("min_height", min_height)
		material.set_shader_parameter("max_height", max_height)
	else: 
		printerr("material is null")
		print_debug("error")
	
var last_resolution = 0
var last_size = 0
var last_height = 0
var last_offset = 0
	
func _process(_delta: float) -> void:
	if resolution != last_resolution \
		or terrain_size != last_size \
		or terrain_max_height != last_height \
		or noise_offset != last_offset:
			generate_terrain()
			last_height = terrain_max_height
			last_offset = noise_offset
			last_resolution = resolution
			last_size = terrain_size
	
	if remove_collision:
		clear_collision()
		remove_collision = false
	if create_collision:
		create_trimesh_collision()
		create_collision = false
		
func generate_collision() -> void:
	clear_collision()
	create_trimesh_collision()
	
func clear_collision() -> void:
	if get_child_count() > 0:
		for children in get_children():
			children.free()
		
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
