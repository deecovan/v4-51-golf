extends RigidBody3D

@export var low_speed = 1.0
@export var low_stop = 0.1
@export var low_decl = 0.02

signal stopped
	
func _integrate_forces(state):
	if (is_lowspeed(state.linear_velocity)):
		state.linear_velocity = add_friction(
			state.linear_velocity, low_stop)
	else:
		state.linear_velocity = add_friction(
			state.linear_velocity, low_decl)
	if state.linear_velocity.length() < low_stop * 2:
		stopped.emit()
		state.linear_velocity = Vector3.ZERO
	## Ball fell off course!
	if position.y < 0:
		get_parent().reload_scene("Ball is out! Reloading...")
		
## Functions

## Check the Speed is Low and verical is 0
func is_lowspeed(speed: Vector3) -> bool:
	return speed.length() < low_speed and speed.y < low_stop

## Add LERP friction simulation for the ball at low speeds
func add_friction(speed: Vector3, v) -> Vector3:
	speed.x = lerp(speed.x, 0.0, v)
	speed.y = lerp(speed.y, 0.0, v)
	speed.z = lerp(speed.z, 0.0, v)
	return speed
