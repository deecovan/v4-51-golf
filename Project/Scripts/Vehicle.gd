extends VehicleBody3D

## Maximum Steering angle in Radians
@export var MAX_STEER  = 0.8
## Maximum Power per Traction wheel
@export var MAX_POWER = 5000
## Used for delta * dmod calculation
@export var dmod = 3
## Car Mass
@export var car_mass = 1000
## Front wheels friction slip ratio
@export var fric_flip_front = 0.75
## Front wheels friction slip ratio
@export var fric_flip_rear = 0.5


func _ready() -> void:
	## Setup car values
	mass = car_mass
	$Wheel3Dfl.wheel_friction_slip = fric_flip_front
	$Wheel3Dfr.wheel_friction_slip = fric_flip_front
	$Wheel3Drl.wheel_friction_slip = fric_flip_rear
	$Wheel3Drr.wheel_friction_slip = fric_flip_rear
	
func _process(delta: float) -> void:
	steering = move_toward(
		steering,
		Input.get_axis("steer_right", "steer_left") * MAX_STEER,
		delta * dmod
		)
	engine_force = Input.get_axis("brake", "accelerate") * MAX_POWER
	
