extends VehicleBody3D

## Maximum Steering angle in Radians
@export var MAX_STEER  = 0.8
## Maximum Power per Traction wheel
@export var MAX_POWER = 5000
## Steering speed
@export var SPD_STEER = 3
## Car Mass
@export var car_mass = 1000
## Front wheels friction slip ratio
@export var fric_slip_front = 0.75 # 1 ## 0.75-1
## Front wheels friction slip ratio
@export var fric_slip_rear = 0.5 # 0.75 ## 0.5-0.75

func _ready() -> void:
	## Setup car values
	mass = car_mass
	$Wheel3Dfl.wheel_friction_slip = fric_slip_front
	$Wheel3Dfr.wheel_friction_slip = fric_slip_front
	$Wheel3Drl.wheel_friction_slip = fric_slip_rear
	$Wheel3Drr.wheel_friction_slip = fric_slip_rear
	## Set Center of Mass from CoM Node
	## Move it Forward to oversteer
	## Backward for understeer but less rear slip
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = $CenterOfMass.position
	
func _process(delta: float) -> void:
	steering = move_toward(
		steering,
		Input.get_axis("steer_right", "steer_left") * MAX_STEER,
		delta * SPD_STEER
		)
	engine_force = Input.get_axis("brake", "accelerate") * MAX_POWER
	## Car fell off course!
	if position.y < -20:
		get_parent().reload_scene("Car is out! Reloading...")
	
