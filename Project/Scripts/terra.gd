extends Node3D

func _ready():
		var map_data = $StaticBody3D/CollisionShape3D.shape.map_data
		var i = 0
		for v in map_data:
			map_data[i] = map_data[i] + randf()/2
			i = i + 1
		print(var_to_str(map_data))
