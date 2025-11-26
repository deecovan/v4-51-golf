extends RigidBody3D

var lowspeed = 1.0
var low_crit = 0.1

signal stopped
	
func _integrate_forces(state):
	if (is_lowspeed(state.linear_velocity)):
		state.linear_velocity = add_friction(state.linear_velocity)
	if state.linear_velocity.length() < 0.2:
		stopped.emit()
		state.linear_velocity = Vector3.ZERO
	# Ball fell off course!
	if position.y < -20:
		get_tree().reload_current_scene()
		
## Functions

## Check the Speed is Low and verical is 0
func is_lowspeed(speed: Vector3) -> bool:
	return speed.length() < lowspeed and speed.y < low_crit

## Add LERP friction simulation for the ball at low speeds
func add_friction(speed: Vector3) -> Vector3:
	speed[0] = lerp(speed[0], 0.0, 0.1)
	speed[1] = lerp(speed[1], 0.0, 0.1)
	speed[2] = lerp(speed[2], 0.0, 0.1)
	return speed
