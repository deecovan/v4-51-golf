extends Node3D

@export var mouse_sensitivity = 150

var angle_change = 1
var power_change = 1
var shots = 0
var power = 0
var hole_dir = 0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	$Ball.position = $Tee.position
	$CameraGimbal/GimbalInner.rotation.x = -0.5
	$CameraGimbal.rotation = $Vehicle.rotation
	$UI.show_message("Get Ready!")
			
func _input(_event):
	use_main_controls(_event)
				
func _process(_delta):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	$CameraGimbal.position = $Vehicle.position
			
## Functions
func _on_ball_stopped() -> void:
	pass

func _on_hole_body_entered(body):
	if body.name == "Ball":
		print_debug('Ball _on_hole_body_entered')

func use_main_controls(_event) -> void:
	## Fullscreen and Reload
	if Input.is_action_just_pressed('reload'):
		print_debug('Reloading scene...')
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed('screen'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN \
			if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
