extends Node3D

@export var cam_speed = PI / 2
@export var zoom_speed = 0.01

@export var camera_lerpx = 3
@export var camera_lerpy = 2
@export var camera_lerpz = 5
@export var camera_rotation = -0.5
@export var camera_zoom = 0.15

var gimbal_rotation_x: float
var gimbal_rotation_y: float
var vehicle_rotation_x: float
var vehicle_rotation_y: float

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
	position.x = lerp(position.x,$"../Vehicle".position.x, delta * camera_lerpx)
	position.y = lerp(position.y,$"../Vehicle".position.y, delta * camera_lerpy)
	position.z = lerp(position.z,$"../Vehicle".position.z, delta * camera_lerpz)
	vehicle_rotation_x = $"../Vehicle".rotation.x
	vehicle_rotation_y = $"../Vehicle".rotation.y
	var x = Input.get_axis("ui_up", "ui_down")
	gimbal_rotation_x = gimbal_rotation_x + x * cam_speed * delta
	$GimbalInner.rotation.x = gimbal_rotation_x + vehicle_rotation_x
	var y = Input.get_axis("ui_right", "ui_left")
	gimbal_rotation_y = gimbal_rotation_y + y * cam_speed * delta
	$GimbalInner.rotation.y = gimbal_rotation_y + vehicle_rotation_y
