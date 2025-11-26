extends VehicleBody3D

var MAX_STEER  = 1

func _process(delta: float) -> void:
	steering = Input.get_axis("steer_left","steer_right")
	
