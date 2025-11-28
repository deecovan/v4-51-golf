extends Node3D

## Keyboard controlled Rotation and Zoom
@export var camera_speed = PI / 2
@export var zoom_speed = 0.01
@export var camera_rotation = -0.6
@export var camera_zoom = 0.2
## Mouse controlled Rotation sensivity and direction
@export var mouse_sensivity = 5000
## -1 normal or +1 inversed
@export var mouse_direction = -1
var gimbal_rotation_x: float
var gimbal_rotation_y: float
var vehicle_rotation_x: float
var vehicle_rotation_y: float

## Camera Follow lerp speed
@export var camera_lerpx = 3
@export var camera_lerpy = 3
@export var camera_lerpz = 3

var zoom: float

func _ready() -> void:
	$GimbalInner.rotation.x = camera_rotation
	zoom = camera_zoom
	gimbal_rotation_x = $GimbalInner.rotation.x
	gimbal_rotation_y = $GimbalInner.rotation.y

func _input(event):
	if event.is_action_pressed("cam_zoom_in"):
		zoom -= zoom_speed
	if event.is_action_pressed("cam_zoom_out"):
		zoom += zoom_speed
		
func _process(delta):
	## Gimbal follow the car, but rotation is modified by player's keyboard
	scale = Vector3.ONE * zoom
	position.x = lerp(
		position.x, $"../Vehicle".position.x, 
		delta * camera_lerpx)
	position.y = lerp(
		position.y, $"../Vehicle".position.y, 
		delta * camera_lerpy)
	position.z =  lerp(
		position.z, $"../Vehicle".position.z, 
		delta * camera_lerpz)
	vehicle_rotation_x = $"../Vehicle".rotation.x
	vehicle_rotation_y = $"../Vehicle".rotation.y
	
	## Keyboard Gimbal rotation
	var x = Input.get_axis("ui_up", "ui_down")
	gimbal_rotation_x = gimbal_rotation_x + x * camera_speed * delta
	var y = Input.get_axis("ui_right", "ui_left")
	gimbal_rotation_y = gimbal_rotation_y + y * camera_speed * delta

	## Mouse Gimbal rotation
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		var mouse_velocity = Input.get_last_mouse_velocity()
		gimbal_rotation_y = (gimbal_rotation_y +
			mouse_direction * mouse_velocity.x / mouse_sensivity)
		gimbal_rotation_x = (gimbal_rotation_x +
		 	mouse_direction * mouse_velocity.y / mouse_sensivity)

	## Apply Gimbal rotation
	$GimbalInner.rotation.x = gimbal_rotation_x + vehicle_rotation_x
	$GimbalInner.rotation.y = gimbal_rotation_y + vehicle_rotation_y
		
