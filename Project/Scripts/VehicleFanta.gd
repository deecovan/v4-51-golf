extends VehicleBody3D

var speedtometer_label

## Car Mass as real_car_mass/grav_mod
## 1250 kg at 1G
## Scaled to 80% 1250*0.8=1000
@export var real_car_mass = 1100 
@export var grav_mod = 1.5
## Maximum Steering speedss
@export var steer_speed = 3
@export var pedal_speed = 1
@export var coasting_speed = 0.01
## Maximum Steering angle in Radians
@export var MAX_STEER  = 0.6

## Next values used for reconfiguring the Vehicle3Ds values
@export var car_linear_damp = 0.5
@export var car_angular_damp = 0.5
@export var car_friction = 0.0
@export var car_rough = false
@export var car_bounce = 0.5
@export var car_absorb = false

## Next values used for reconfiguring the Wheel3Ds values
## Front wheels friction slip ratio ## 0.65
@export var fric_slip_front = 2.4
## Rear wheels friction slip ratio ## 0.65
@export var fric_slip_rear = 2.0
## Typical racing car damper ratios are 0.65-0.7 
## in ride where 1 is 100% critical damping
## Front wheels damper compression ## 0.8
@export var damp_compr_front = 0.5
## Front wheels damper relaxation ## 0.88
@export var damp_relax_front = 0.6
## Rear ## 0.7 0.77
@export var damp_compr_rear = 0.4
@export var damp_relax_rear = 0.5
## Rest, Travel, Stiff, MaxV
@export var rest_front = 0.075
@export var rest_rear = 0.08
@export var travel_front = 0.1
@export var travel_rear = 0.1
@export var stiff_front = 120
@export var stiff_rear = 110
@export var max_force_front = 20000
@export var max_force_rear = 20000

## MAX_POWER Used as power for gears (as PFG) 
@export var MAX_POWER = 20000.0 # per each Traction wheel
## SuperSpeed for this car is 140ms(500KPH) 
@export var MAX_SPEED = 140.0
## Must have 28ms(100kph) in 3.5 seconds

## Array values of Used power for PFG 
var power_curve: Array = [
	0.06, 0.12, 0.25, 0.50, 0.70, 
	0.85, 0.95, 1.00, 1.00, 0.95, 
	0.85, 0.60, 0.30, 0.10, 0.01, 0.00 
]

func _ready() -> void:
	
	if true:
		## Setup Vehicle3D values
		mass = real_car_mass/grav_mod
		gravity_scale = grav_mod
		linear_damp = car_linear_damp
		angular_damp = car_angular_damp
		## Setup Vehicle3D Physics Material
		physics_material_override.friction = car_friction
		physics_material_override.rough = car_rough
		physics_material_override.bounce = car_bounce
		physics_material_override.absorbent = car_absorb
		
		## Setup Wheel2Ds Front and Rear values
		## Grip
		$Wheel3Dfl.wheel_friction_slip = fric_slip_front
		$Wheel3Dfr.wheel_friction_slip = fric_slip_front
		$Wheel3Drl.wheel_friction_slip = fric_slip_rear
		$Wheel3Drr.wheel_friction_slip = fric_slip_rear
		### Damper
		$Wheel3Dfl.damping_compression = damp_compr_front
		$Wheel3Dfr.damping_compression = damp_compr_front
		$Wheel3Drl.damping_compression = damp_compr_rear
		$Wheel3Drr.damping_compression = damp_compr_rear
		$Wheel3Dfl.damping_relaxation = damp_relax_front
		$Wheel3Dfr.damping_relaxation = damp_relax_front
		$Wheel3Drl.damping_relaxation = damp_relax_rear
		$Wheel3Drr.damping_relaxation = damp_relax_rear
		### Rest
		$Wheel3Dfl.wheel_rest_length = rest_front
		$Wheel3Dfr.wheel_rest_length = rest_front
		$Wheel3Drl.wheel_rest_length = rest_rear
		$Wheel3Drr.wheel_rest_length = rest_rear
		### Travel
		$Wheel3Dfl.suspension_travel = travel_front
		$Wheel3Dfr.suspension_travel = travel_front
		$Wheel3Drl.suspension_travel = travel_rear
		$Wheel3Drr.suspension_travel = travel_rear
		### Stiffness
		$Wheel3Dfl.suspension_stiffness = stiff_front
		$Wheel3Dfr.suspension_stiffness = stiff_front
		$Wheel3Drl.suspension_stiffness = stiff_rear
		$Wheel3Drr.suspension_stiffness = stiff_rear
		### Maximum Suspension force
		$Wheel3Dfl.suspension_max_force = max_force_front
		$Wheel3Dfr.suspension_max_force = max_force_front
		$Wheel3Drl.suspension_max_force = max_force_rear
		$Wheel3Drr.suspension_max_force = max_force_rear

	## Set Center of Mass from CenterOfMass Node
	## Move it Forward to oversteer
	## Backward for understeer but less rear slip
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = $CenterOfMass.position
	
	## Randomize initial rotation
	rotation = randomis(rotation, PI)
	
	## Init PFG screen
	$"../UI".call_draw_curve(power_curve)
	speedtometer_label = $"../UI/MarginContainer/VBoxContainer/Speedometer/Label"
	
func _process(delta: float) -> void:
	steering = move_toward(
		steering,
		Input.get_axis("steer_right", "steer_left") * MAX_STEER,
		delta * steer_speed
		)
	
	## Match Vehicle speed to power_curve to get engine_force
	var pedal_text
	if Input.is_action_pressed("accelerate"):
		engine_force = lerp(engine_force, MAX_POWER, pedal_speed * delta)
		pedal_text = "Accel"
		## Match force to power_curve
		var max_curve_index = power_curve.size() - 5
		var speed_index = clamp( ## clamp maximal values
			## for maximal gear, starting from index 2, limited to index -5
			2 + linear_velocity.length()/(MAX_SPEED/max_curve_index),  
			2, power_curve.size() - 5)      ## Test it again
		var match_power = power_curve[speed_index] * MAX_POWER
		engine_force = clamp(engine_force, 0, match_power)
		## Tested fixed values: match_power=power_curve, Rest, Travel, Stiff, MaxV
		#printt(int(linear_velocity.length()),speed_index, match_power)
	elif Input.is_action_pressed("brake"):
		engine_force = lerp(engine_force, -MAX_POWER, pedal_speed * delta)
		pedal_text = "Brake"
	## Else: Coasting
	else: 
		engine_force = 0.0
		pedal_text = "Coast"
	## Update UI
	speedtometer_label.text = (
		pedal_text + ' ' + 
		str(int(engine_force)) + ' f, ' +
		str(int(linear_velocity.length()*3.6)) + ' kph ' )
	
	## Car fell off course!
	if position.y < 0:
		get_parent().reload_scene("Car is out! Reloading...")
	
func randomis(v: Vector3, mult) -> Vector3:
	return v + mult * Vector3(
		(randf()-0.49)/10,(randf()-0.49)/10,(randf()-0.49)/10)
