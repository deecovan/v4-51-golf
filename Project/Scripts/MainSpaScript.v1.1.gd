extends Node3D

@export var DEBUG = true
var vehicle: VehicleBody3D
var UI: CanvasLayer

func _ready():
	## Use unshaded for tests
	if DEBUG:
		var viewport = get_viewport()
		viewport.debug_draw = viewport.DEBUG_DRAW_UNSHADED
	
	var root = get_tree().get_root().get_child(0)
	var find = root.find_children("UI")
	UI = find[0]
	find = root.find_children("Vehicle")
	vehicle = find[0]
	## Using Debug Draw not shaded
	UI.show_message("Spa Flat v1.1 Ready!")
			
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.is_echo():
		use_main_controls(event)
				
func _process(_delta):
	if Input.is_action_just_pressed('restore'):
		UI.show_message("Restoring...")
		vehicle.position.y = vehicle.position.y + 1
		vehicle.position = Vector3(
			vehicle.position.x + randf(),
			vehicle.position.y + 1,
			vehicle.position.z +  randf())
		vehicle.rotation = Vector3.ZERO
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
	if Input.is_action_just_pressed('Show Info'):
		UI.show_info()
	if Input.is_action_just_pressed('Hide Info'):
		UI.hide_info()
	if Input.is_action_just_pressed('reload'):
		get_tree().change_scene_to_file("res://Scenes/MainSpaFlat.v1.2.tscn")
	if Input.is_action_just_pressed('screen'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN \
			if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
	## Optional: Toggle between debug draw modes using a key press (e.g., 'P')
	if Input.is_action_just_pressed('viewport'):
		# Cycle through the available debug draw modes
		# (DEBUG_DRAW_DISABLED, DEBUG_DRAW_WIREFRAME, DEBUG_DRAW_OVERDRAW, DEBUG_DRAW_UNSHADED)
		var viewport = get_viewport()
		viewport.debug_draw = (viewport.debug_draw + 1) % 5
		
	## Change Main scene
	if Input.is_action_just_pressed('next_scene'):
		get_tree().change_scene_to_file("res://Scenes/MainSpaHeight.v1.1.tscn")
			
func reload_scene(message):
	UI.show_message(message)
	await get_tree().create_timer(2).timeout
	get_tree().call_deferred("reload_current_scene")
