extends MeshInstance3D

@export var noised = 1.0/40

func _ready():
		var cs = $CollisionShape3D2
		var i = 0
		for v in cs.shape.map_data:
			cs.shape.map_data[i] = (
				cs.shape.map_data[i] + (randf() - 0.5) * noised)
			i = i + 1
