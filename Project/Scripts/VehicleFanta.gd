extends VehicleBody3D

var speedtometer_label
var reverse =  false
var DEBUG = false

@export var grav_scale = 2.0
## Maximum Steering speedss
@export var steer_speed = 1.4
@export var pedal_speed = 0.75
## Vehicle3D body braking force
@export var use_wheel_brake = true
@export var vehicle_brake_force = 10.0
## Wheel3D braking force and balance
@export var wheel_brake_force = 10.0
@export var front_brake_power = 1.2
@export var rear_brake_power = 0.8
@export var pedal_brake_speed = 2.0
## Coasting starting value
@export var coast_init = 0.5
## Coasting lerp speed
@export var engine_coast = 0.1
## Maximum Steering angle in Radians
@export var MAX_STEER  = 0.55
## Next values used for reconfiguring the Vehicle3Ds values
@export var car_linear_damp = 0.5
@export var car_angular_damp = 0.5
@export var car_friction = 0.0
@export var car_rough = false
@export var car_bounce = 0.1
@export var car_absorb = false

enum States { ACCELERATING, BRAKING, COASTING, REVERSING}
var state = States.COASTING
var engine_index: int = 0

## Next values used for reconfiguring the Wheel3Ds values
## Front wheels friction slip ratio ## 0.65
@export var fric_slip_front = 1.3
## Rear wheels friction slip ratio ## 0.65
@export var fric_slip_rear = 1.3 
## @HACK Acceleration multiplier for rear slip
@export var fric_slip_rear_mult = 0.7
## Typical racing car damper ratios are 0.65-0.7 
## in ride where 1 is 100% critical damping
## Front wheels damper compression ## 0.8
@export var damp_compr_front = 0.75
## Front wheels damper relaxation ## 0.88
@export var damp_relax_front = 15.0
## Rear ## 0.7 0.77
@export var damp_compr_rear = 0.75
@export var damp_relax_rear = 15.0
## Rest, Travel, Stiff, MaxV
@export var rest_front = 0.12
@export var rest_rear = 0.11
@export var travel_front = 0.2
@export var travel_rear = 0.2
@export var stiff_front = 380
@export var stiff_rear = 200
@export var max_force_front = 1600
@export var max_force_rear = 1600
@export var MAX_SPEED = 111.0
@export var MAX_POWER = 750.0

## Array values of Used power for PFG 
var power_curve: Array = [
	0.06, 0.12, 0.25, 0.50, 0.70, 
	0.85, 0.95, 1.00, 1.00, 0.95, 
	0.85, 0.60, 0.30, 0.10, 0.01, 0.00 
]
enum engine_index_list {Rear, Neutral, First, Second, Third, Fourth, Fifth, Sixth, Seventh, Eighth}
var root: Node3D
var UI: CanvasLayer
var Analometer: Control
var rem_linear_velocity = Vector3.ZERO

func _ready() -> void:
	root = get_tree().get_root().get_child(0)
	UI = root.find_children("UI")[0]
	Analometer = UI.get_analometer()
	
	## Setup Vehicle3D values
	gravity_scale = grav_scale
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
	UI.call_draw_curve(power_curve)
	
func _physics_process(delta: float) -> void:
	steering = move_toward(
		steering,
		Input.get_axis("steer_right", "steer_left") * MAX_STEER,
		delta * steer_speed
		)
	if Input.is_action_just_pressed("reverse"):
		reverse = !reverse
	
## Match Vehicle speed to power_curve to get engine_force
	## Remove reverse
	engine_force = abs(engine_force)
	if Input.is_action_pressed("accelerate"):
		if state != States.ACCELERATING:
			state = States.ACCELERATING
		engine_force = lerp(engine_force, MAX_POWER, pedal_speed * delta)
		## Match force to power_curve
		var max_curve_index = power_curve.size() - 5
		var speed_index = clamp( ## clamp maximal values
			## for maximal gear, starting from index 2, limited to index -5
			2 + linear_velocity.length()/(MAX_SPEED/max_curve_index),  
			2, power_curve.size() - 5)      ## @TESTED
		var match_power = power_curve[speed_index] * MAX_POWER
		engine_index = speed_index
		engine_force = clamp(engine_force, 0, match_power)
		brake = 0.0
		## Else: Braking with Engine LERP down
	elif Input.is_action_pressed("brake"):
		state = States.BRAKING
		engine_force = lerp(
			engine_force, 0.0, pedal_brake_speed * delta)
		## Braking with Vehicle3D
		if not use_wheel_brake:
			brake = vehicle_brake_force
		## Braking with Wheels
		else:
			$Wheel3Dfl.brake = wheel_brake_force * front_brake_power
			$Wheel3Dfr.brake = wheel_brake_force * front_brake_power
			$Wheel3Drl.brake = wheel_brake_force * rear_brake_power
			$Wheel3Drr.brake = wheel_brake_force * rear_brake_power
		## @HACK Simulate braking Friction Slip
		#$Wheel3Drl.wheel_friction_slip = fric_slip_rear / mult_slip_rear
		#$Wheel3Drr.wheel_friction_slip = fric_slip_rear / mult_slip_rear
	## Else: Coasting with Engine LERP down
	else: 
		if state != States.COASTING:
			## Decrease engine power on state changed
			engine_force = engine_force * coast_init
			state = States.COASTING
		brake = 0.0
		engine_force = lerp(engine_force, 0.0, engine_coast * delta)
	## Apply reverse
	if reverse:
		state = States.REVERSING
		engine_force = - engine_force
		
	## @HACK Simulate Accelerating Friction Slip
	if state == States.ACCELERATING:
		$Wheel3Drl.wheel_friction_slip = fric_slip_rear
		$Wheel3Drr.wheel_friction_slip = fric_slip_rear
	else:
		$Wheel3Drl.wheel_friction_slip = fric_slip_rear * fric_slip_rear_mult
		$Wheel3Drr.wheel_friction_slip = fric_slip_rear * fric_slip_rear_mult

	## Update UI logs screen
	#if root.DEBUG:
		#UI.logs_clr_text()
		#UI.logs_add_text("\n Engine power        : %6.2f" % engine_force)
		#UI.logs_add_text("\n Engine index        : %6s" % engine_index_list.keys()[engine_index])
		#UI.logs_add_text("\n Angular_velocity.y  : %6.2f" % rad_to_deg(angular_velocity.y) + " deg")
		#UI.logs_add_text("\n  Linear_velocity.l  : %6.2f" % (linear_velocity.length() * 3.6) + " kph" )
		#UI.logs_add_text("\n Front friction_slip : %6.2f" % $Wheel3Dfl.wheel_friction_slip)
		#UI.logs_add_text("\n  Rear friction_slip : %6.2f" % $Wheel3Drl.wheel_friction_slip)
		#UI.logs_add_text("\n Front wheel rotation: %6.2f" % $Wheel3Dfl.get_rpm() + " rpm" )
		#UI.logs_add_text("\n  Rear wheel rotation: %6.2f" % $Wheel3Drl.get_rpm() + " kph" )

	## @HACK Simulate Braking Drift
	if state == States.BRAKING:
		pass
		
	## Update UI
	UI.set_speedometer_label(
		States.keys()[state] + ' ' + engine_index_list.keys()[engine_index])
	
	rotate_speed_pt(linear_velocity.length() * 3.6)
	rotate_speed_ps(get_delta_velocity(delta), delta)
	rotate_tacho_pt(($Wheel3Drl.get_rpm() + $Wheel3Drl.get_rpm()) / 2)
	rotate_tacho_ps(engine_force, delta)
		
	## Car fell off course!
	if position.y < -50:
		UI.show_message("Car is out! Reload with [F5]")

func rotate_speed_pt(speedf: float) -> void:
	var speedr = 0.0
	var min_rad = Analometer.get_min_rad() 
	var max_rad = Analometer.get_max_rad() 
	var max_spd = Analometer.get_max_spd()
	speedr = min_rad + (
		(max_rad-min_rad) / max_spd
		) * speedf
	Analometer.rotate_speed_pt(speedr)
	
func rotate_tacho_pt(tachof: float) -> void:
	var tachor = 0.0
	var min_rad = Analometer.get_min_rad() 
	var max_rad = Analometer.get_max_rad() 
	var max_rot = Analometer.get_max_rot() 
	tachor = min_rad + (
		(max_rad - min_rad) / max_rot
		) * tachof
	Analometer.rotate_tacho_pt(tachor)
		
func rotate_tacho_ps(tachof: float, delta) -> void:
	var tachor = 0.0
	var min_rad = Analometer.get_min_rad() 
	var max_rad = Analometer.get_max_rad() 
	var max_tac = Analometer.get_max_tac() 
	var tach_ps = Analometer.get_tach_ps() 
	tachor = min_rad + (
		(max_rad - min_rad) / max_tac
		) * tachof
	Analometer.rotate_tacho_ps(
		lerp(tach_ps, tachor, PI*delta))
	
func rotate_speed_ps(deltavf: float, delta) -> void:
	var deltavr = 0.0
	var min_rad = Analometer.get_min_rad() 
	var max_rad = Analometer.get_max_rad() 
	var max_dev = Analometer.get_max_dev() 
	var speed_ps = Analometer.get_speed_ps() 
	deltavr = min_rad + (
		(max_rad - min_rad) / max_dev
		) * deltavf
	Analometer.rotate_speed_ps(
		lerp(speed_ps, deltavr, delta))

func get_delta_velocity(delta) -> float:
	## Remember last velocity
	var rem_vel = rem_linear_velocity
	rem_linear_velocity = linear_velocity
	var cur_vel = linear_velocity
	## Gat Vector diff
	var delta_vel = cur_vel - rem_vel
	return (delta_vel.length() * 3.6) / delta
	
func randomis(v: Vector3, mult) -> Vector3:
	return v + mult * Vector3(
		(randf()-0.49)/10,(randf()-0.49)/10,(randf()-0.49)/10)
