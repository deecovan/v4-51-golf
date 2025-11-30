extends MeshInstance3D

@export var noised = 1.0/20

func _ready():
		var cs = $StaticBody3D/CollisionShape3D
		var i = 0
		for v in cs.shape.map_data:
			cs.shape.map_data[i] = cs.shape.map_data[i] + randf() * noised
			i = i + 1
