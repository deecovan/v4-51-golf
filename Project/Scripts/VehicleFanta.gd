extends VehicleBody3D

var speedtometer_label
var REVERSE =  false
var DEBUG = false

## Values for curve Fanta_Curve_damp02
## Real maximum 240
## Tested fixed waaw
@export var car_linear_damp = 0.2
## @TODO merge ZC's aerodynamic from f9cfddd zc/aeroDrag
@export var vehicle_mass = 1000.0
@export var grav_scale = 1.0
@export var MAX_SPEED = 100.0
@export var MAX_POWER = 6600.0

## Maximum Steering speed
@export var steer_control_speed = 0.8
## Maximum Braking speed
@export var brake_control_speed = 0.6
## Control's lerp speed
# Use 0..10 for keyboard or controller
# Use 100 for racing wheels
@export var control_speed = 4.0
## Vehicle3D body braking force
@export var use_wheel_brake = true
## Applied with Use Wheel Brake = false
@export var vehicle_brake_force = 100.0
## Wheel3D braking force and balance
@export var wheel_brake_force = 80.0
## wheel_brake_force multiplier
@export var front_brake_force = 1.0
## wheel_brake_force multiplier
@export var rear_brake_force = 1.2
## Brake lerp speed
@export var pedal_brake_speed = 1.6
## hand_brake_force multiplier
@export var hand_brake_force = 1.5
## Coasting starting value
@export var coast_init = 0.8
## Coasting lerp speed
@export var engine_coast = 0.1
## Maximum Steering angle in Radians
@export var MAX_STEER  = 0.4
## Next values used for reconfiguring the Vehicle3Ds values
@export var car_angular_damp = 0.0
@export var car_friction = 0.0
@export var car_rough = false
@export var car_bounce = 0.25
@export var car_absorb = false

## Next values used for reconfiguring the Wheel3Ds values
## Front wheels friction slip ratio ## 0.65
@export var fric_slip_front = 2.2
## Rear wheels friction slip ratio ## 0.65
@export var fric_slip_rear = 2.0 
## @HACK Acceleration multiplier for rear slip. Used if NOT accelerating.
@export var fric_slip_rear_demult = 0.8
## Typical racing car damper ratios are 0.65-0.7 
## in ride where 1 is 100% critical damping
## Front wheels damper compression ## 0.8
@export var damp_compr_front = 0.75
## Front wheels damper relaxation ## 0.88
@export var damp_relax_front = 15.0
## Rear ## 0.7 0.77
@export var damp_compr_rear = 0.75
## Rear wheels damper relaxation ## 0.88
@export var damp_relax_rear = 15.0
## Rest, Travel, Stiff, MaxV
@export var rest_front = 0.12
@export var rest_rear = 0.11
@export var travel_front = 0.2
@export var travel_rear = 0.2
@export var stiff_front = 380
@export var stiff_rear = 200
@export var max_force_front = 16000
@export var max_force_rear = 16000
## (-Z) value (meters) - Move Center Of Mass backward, (-Y): up
@export var COM_MOD_VECTOR = Vector3(0.0,0.2,-0.3)
@export var scale_curve: Curve
var scale_array : Array

## Array values of power function.
## @TODO we need to implement the engine power function.

enum States { ACCELERATING, BRAKING, COASTING, REVERSING}
var engine_state = States.COASTING
enum engine_index_list {Rear, Neutral, First, Second, Third, Fourth, Fifth, Sixth, Seventh, Eighth}
var engine_index: int = 0
var acceleration_power = 0.0
var matching_power = 0.0
var accelerating = 0.0

var root: Node3D
var UI: CanvasLayer
var Analometer: Control
var rem_linear_velocity = Vector3.ZERO

func _ready() -> void:
	var loader = get_tree().get_root().get_child(0)
	UI = loader.get_node("UI")
	Analometer = UI.get_analometer()
	
	## Setup Vehicle3D values
	mass = vehicle_mass
	gravity_scale = grav_scale
	linear_damp = car_linear_damp
	angular_damp = car_angular_damp
	## Setup Vehicle3D Physics Material
	## Use this block only if the physics_material_override is used
	#physics_material_override.friction = car_friction
	#physics_material_override.rough = car_rough
	#physics_material_override.bounce = car_bounce
	#physics_material_override.absorbent = car_absorb
	
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

	## Apply Max Power to tachometer
	Analometer.set_max_tac(MAX_POWER) 
	
	## Set Center of Mass from CenterOfMass Node
	## Move it Forward to oversteer
	## Backward for understeer but less rear slip
	center_of_mass_mode = RigidBody3D.CENTER_OF_MASS_MODE_CUSTOM
	center_of_mass = $CenterOfMass.position + COM_MOD_VECTOR
	
	## Randomize initial rotation
	# rotation = randomis(rotation, PI)
	
	## Init PFG screen
	# _scale_curve.sample_baked(i)*MAX_POWER
	for i in 100:
		scale_array.append(scale_curve.sample_baked(i/100.0)*MAX_POWER)
	UI.call_draw_curve(scale_array)
	
func _physics_process(delta: float) -> void:
			
	## Reverse in the simpliest way
	if Input.is_action_just_pressed("reverse"):
		REVERSE = !REVERSE
		
	## Use controller's axes, joy or key input
	var _steering = Input.get_axis("steer_right", "steer_left") * MAX_STEER
	var _accelerating = Input.get_axis("brake", "accelerate")
	## Simulate axes if keys are used
	if Input.is_action_pressed("steer_right")\
		or Input.is_action_pressed("steer_left"):
			steering = lerp(steering, _steering, 
			steer_control_speed * control_speed * delta)
	else: 
		## Do Not LERP, move linearly
		steering = move_toward(steering, 0.0 , 
			steer_control_speed * delta)
	## Using Brake
	if Input.is_action_pressed("brake")\
		or Input.is_action_pressed("accelerate"):
			accelerating = lerp(accelerating, _accelerating, 
			brake_control_speed * control_speed * delta)
								   
	## Set acceleration state @CHANGED
	if _accelerating > 0:
		engine_state = States.ACCELERATING
	## Else: Braking key
	elif _accelerating < 0:
		engine_state = States.BRAKING

	## Else: Coasting with Engine LERP down
	else: 
		if engine_state != States.COASTING:
			## Decrease engine power on state changed
			engine_state = States.COASTING
			engine_force = engine_force * coast_init
		## Engine coasting lerp down
		engine_force = lerp(engine_force, 0.0, engine_coast * delta)

	## Process the curent state
	if engine_state == States.ACCELERATING:
		acceleration_power = MAX_POWER * accelerating
		## Remove REVERSE
		engine_force = abs(engine_force)
		## Apply accelerating
		matching_power = engine_match_power(
			acceleration_power, 
			scale_curve, 
			delta)
		## Match force to scale_curve
		engine_force = lerp(
			engine_force, 
			clamp(matching_power, 0, matching_power), 
			control_speed * delta) 
		## Apply REVERSE
	if REVERSE:
		engine_state = States.REVERSING
		engine_force = - engine_force
	
	if engine_state == States.BRAKING:
		## Drop engine
		engine_force = lerp(engine_force, 0.0, control_speed * delta)
		## Braking with Vehicle3D
		if not use_wheel_brake:
			var set_vehicle_brake_force = \
				-accelerating * vehicle_brake_force
			change_vehicle_brake(set_vehicle_brake_force, delta)
		## Braking with Wheelsa
		else:
			var set_wheel_brake_force = \
				-accelerating * vehicle_brake_force
			change_wheel_brake(set_wheel_brake_force, 
				front_brake_force, rear_brake_force, delta)
	else: 
		change_vehicle_brake(0.0, delta)
		change_wheel_brake(0.0, 0.0, 0.0, delta)

	## @HACK Simulate Accelerating Friction Slip
	## @NEW Using HandBrake at any time
	if Input.is_action_pressed("handbrake"):
		## Function?
		set_fric_slip_rear(fric_slip_rear)
		var set_brake_force = \
			hand_brake_force * vehicle_brake_force
		if not use_wheel_brake:
			change_vehicle_brake(set_brake_force, delta)
		else:
			change_wheel_brake(set_brake_force, 
				front_brake_force, rear_brake_force, delta)
			set_fric_slip_rear(fric_slip_rear / fric_slip_rear_demult)
		
	## @HACK Simulate Braking Drift
	if engine_state == States.BRAKING:
		pass
		
	## Update UI
	UI.set_speedometer_label(
		States.keys()[engine_state] + ' ' + engine_index_list.keys()[engine_index])
	rotate_speed_pt(linear_velocity.length() * 3.6)
	rotate_speed_ps(get_delta_velocity(delta), delta)
	rotate_tacho_pt(($Wheel3Drl.get_rpm() + $Wheel3Drl.get_rpm()) / 2)
	rotate_tacho_ps(engine_force, delta)
	
	UI.logs_clr_text()
	UI.logs_add_text("\n steering.....: %6.2f" % steering)
	UI.logs_add_text("\n accelerating.: %6.2f" % accelerating)
	UI.logs_add_text("\n engine brake.: %6.2f" % brake)
	UI.logs_add_text("\n wheel f.brake: %6.2f" % $Wheel3Dfl.brake)
	UI.logs_add_text("\n wheel r.brake: %6.2f" % $Wheel3Drl.brake)
	UI.logs_add_text("\n engine_force.: %6.2f" % engine_force)
	UI.logs_add_text("\n matching_pow.: %6.2f" % matching_power)
	UI.logs_add_text("\n engine_index.: %6.2f" % engine_index)
	UI.logs_add_text("\n eng.ind.text.:   %s"  % engine_index_list.keys()[engine_index])
	UI.logs_add_text("\n STATE........:   %s"  % States.keys()[engine_state])
	UI.logs_add_text("\n REVERSE......:   %s"   % var_to_str(REVERSE))
		
	## Car fell off course!
	if position.y < -50:
		UI.show_message("Car is out! Reload with [F5]")
		
func set_fric_slip_rear(_fric_slip_rear) -> void:
	$Wheel3Drl.wheel_friction_slip = _fric_slip_rear
	$Wheel3Drr.wheel_friction_slip = _fric_slip_rear

## Apply Vehicle Brake lerp
func change_vehicle_brake(_vehicle_brake_force, _delta) -> void:
	brake = lerp(brake, _vehicle_brake_force, _delta)

## Apply Wheels Brake lerp
## Using HandBrake
func change_wheel_brake(_brake_force, _front_brake_power, \
	_rear_brake_power, _delta) -> void:
	$Wheel3Dfl.brake = _brake_force * _front_brake_power
	$Wheel3Dfr.brake = _brake_force * _front_brake_power
## Using HandBrake at any time don't remove acceleration
	if engine_state != States.ACCELERATING:
		$Wheel3Drl.brake = _brake_force * _rear_brake_power
		$Wheel3Drr.brake = _brake_force * _rear_brake_power


func engine_match_power(_acceleration_power, _scale_curve:Curve, _delta) -> float:
		var normalized_speed=linear_velocity.length()/MAX_SPEED
		var match_power = _scale_curve.sample_baked(normalized_speed)*MAX_POWER
		return match_power
		
func set_engine_index(_speed_index) -> void:
	engine_index = _speed_index

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
