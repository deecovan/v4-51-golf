extends VehicleBody3D

## @REMEMBER values tested with Dodge scaled 0.8 1000kg 1.5G
## Maximum Power per Traction wheel
@export var MAX_POWER = 5000 # per each Traction wheel
## Steering speed
@export var SPD_STEER = 3
## Maximum Steering angle in Radians
@export var MAX_STEER  = 0.6
## Car Mass as car_mass/grav_mod
@export var car_mass = 1000
@export var grav_mod = 1.5

## Front wheels friction slip ratio
@export var fric_slip_front = 0.6
## Rear wheels friction slip ratio
@export var fric_slip_rear = 0.5

## Typical racing car damper ratios are 0.65-0.7 
## in ride where 1 is 100% critical damping
## Front wheels damper compression
@export var damp_compr_front = 0.8
## Front wheels damper relaxation
@export var damp_relax_front = 0.88
## Rear
@export var damp_compr_rear = 0.7
@export var damp_relax_rear = 0.77
## Rest, Travel, Stiff, MaxV
@export var rest_front = 0.8
@export var rest_rear = 0.8
@export var travel_front = 0.1
@export var travel_rear = 0.1
@export var stiff_front = 160
@export var stiff_rear = 160
@export var max_force_front = 16000
@export var max_force_rear = 14000


var power_curve: Array = [
	0.03, 0.06, 0.12, 0.25, 0.50, 
	0.70, 0.85, 0.95, 1.00, 0.95, 
	0.85, 0.55, 0.20, 0.05, 0.01 
]

func _ready() -> void:
	## Setup car values
	mass = car_mass/grav_mod
	gravity_scale = grav_mod
	## @TODO Compare ALL Vehicle vars with current saved working
	## Grip
	#$Wheel3Dfl.wheel_friction_slip = fric_slip_front
	#$Wheel3Dfr.wheel_friction_slip = fric_slip_front
	#$Wheel3Drl.wheel_friction_slip = fric_slip_rear
	#$Wheel3Drr.wheel_friction_slip = fric_slip_rear
	### Damper
	#$Wheel3Dfl.damping_compression = damp_compr_front
	#$Wheel3Dfr.damping_compression = damp_compr_front
	#$Wheel3Drl.damping_compression = damp_compr_rear
	#$Wheel3Drr.damping_compression = damp_compr_front
	#$Wheel3Dfl.damping_relaxation = damp_relax_rear
	#$Wheel3Dfr.damping_relaxation = damp_relax_rear
	#$Wheel3Drl.damping_relaxation = damp_relax_rear
	#$Wheel3Drr.damping_relaxation = damp_relax_rear
	### Rest
	#$Wheel3Dfl.wheel_rest_length = rest_front
	#$Wheel3Dfr.wheel_rest_length = rest_front
	#$Wheel3Drl.wheel_rest_length = rest_rear
	#$Wheel3Drr.wheel_rest_length = rest_rear
	### Travel
	#$Wheel3Dfl.suspension_travel = travel_front
	#$Wheel3Dfr.suspension_travel = travel_front
	#$Wheel3Drl.suspension_travel = travel_rear
	#$Wheel3Drr.suspension_travel = travel_rear
	### Stiffness
	#$Wheel3Dfl.suspension_stiffness = stiff_front
	#$Wheel3Dfr.suspension_stiffness = stiff_front
	#$Wheel3Drl.suspension_stiffness = stiff_rear
	#$Wheel3Drr.suspension_stiffness = stiff_rear
	### Maximum suspension force
	#$Wheel3Dfl.suspension_max_force = max_force_front
	#$Wheel3Dfr.suspension_max_force = max_force_front
	#$Wheel3Drl.suspension_max_force = max_force_rear
	#$Wheel3Drr.suspension_max_force = max_force_rear
	## Set Center of Mass from CoM Node
	## Move it Forward to oversteer
	## Backward for understeer but less rear slip
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = $CenterOfMass.position
	## Randomize initial rotation
	rotation = randomis(rotation, PI)
	
	$"../UI".call_draw_curve(power_curve)
	
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
	
func randomis(v: Vector3, mult) -> Vector3:
	return v + mult * Vector3(
		(randf()-0.49)/10,(randf()-0.49)/10,(randf()-0.49)/10)
