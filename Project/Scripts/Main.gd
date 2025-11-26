extends Node3D

@export var mouse_sensitivity = 150

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Ball.position = $Tee.position
	$CameraGimbal/GimbalInner.rotation.x = -0.5
	$UI.show_message("Get Ready!")
			
func _input(_event):
	use_main_controls(_event)
				
func _process(_delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	$CameraGimbal.position = $Vehicle.position
	$CameraGimbal.rotation = $Vehicle.rotation
			
## Functions

## @SIGNAL Ball.stopped.emit()
func _on_ball_stopped() -> void:
	pass

func _on_hole_body_entered(body):
	if body.name == "Ball":
		print_debug('Ball _on_hole_body_entered')

## Fullscreen and Reload Scene
func use_main_controls(_event) -> void:
	if Input.is_action_just_pressed('reload'):
		print_debug('Reloading scene...')
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed('screen'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN \
			if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
