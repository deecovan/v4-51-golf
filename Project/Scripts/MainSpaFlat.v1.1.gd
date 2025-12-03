extends Node3D

@export var mouse_sensitivity = 150
var vehicle: Node
var UI: Node

func _ready():
	var root = get_tree().get_root().get_child(0)
	var find = root.find_children("UI")
	UI = find[0]
	find = root.find_children("Vehicle")
	vehicle = find[0]
	## Using Debug Draw not shaded
	get_viewport().debug_draw = Viewport.DEBUG_DRAW_UNSHADED
	UI.show_message("Get Ready!")
			
func _input(_event):
	use_main_controls(_event)
				
func _process(_delta):
	if Input.is_action_just_pressed('restore'):
		UI.show_message("Restoring...")
		vehicle.position.y = vehicle.position.y + 1
		vehicle.position = Vector3(
			vehicle.position.x + randf(),
			vehicle.position.y + 1,
			vehicle.position.z +  randf())
		vehicle.rotation = Vector3(
			0,
			vehicle.rotation.y,
			0)
		vehicle.constant_force = Vector3.ZERO
		vehicle.constant_torque = Vector3.ZERO
	if Input.is_action_just_pressed('help'):
		UI.show_message_again()

## @SIGNAL Ball.stopped.emit()
func _on_ball_stopped() -> void:
	pass

## @SIGNAL Ball._on_hole_body_entered(body)
func _on_hole_body_entered(body):
	if body.name == "Ball":
		reload_scene('Eagle! Reloading...')

## Fullscreen and Reload Scene
func use_main_controls(_event) -> void:
	if Input.is_action_just_pressed('reload'):
		reload_scene('Reloading...')
	if Input.is_action_just_pressed('screen'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN \
			if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
	## Optional: Toggle between debug draw modes using a key press (e.g., 'P')
	if Input.is_action_just_pressed('viewport'):
		var viewport = get_viewport()
		# Cycle through the available debug draw modes
		# (DEBUG_DRAW_DISABLED, DEBUG_DRAW_WIREFRAME, DEBUG_DRAW_OVERDRAW, DEBUG_DRAW_UNSHADED)
		viewport.debug_draw = (viewport.debug_draw + 1) % 5
			
func reload_scene(message):
	UI.show_message(message)
	await get_tree().create_timer(2).timeout
	get_tree().call_deferred("reload_current_scene")
