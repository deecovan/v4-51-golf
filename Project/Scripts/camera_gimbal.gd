extends Node3D

## Keyboard controlled Rotation and Zoom
@export var camera_speed = PI / 2
@export var camera_FOV = 32
@export var zoom_min = 0.8
@export var zoom_max = 2
@export var zoom_speed = 0.2
var zoom = zoom_min
var zoom_z_position: float
var zoom_z_position_min: float
var zoom_z_position_max: float
@export var zoom_z_position_step = 2
## Tween larger values to slow down
@export var tween_speed = 8.0
@export var tween_follow_speed = 8.0
## Mouse controlled Rotation sensivity and direction
@export var mouse_sensivity = 5000
## -1 normal or +1 inversed
@export var mouse_direction = -1
var gimbal_offset: Vector3
var gimbal_rotation_x: float
var gimbal_rotation_y: float
var gimbal_rotation_z: float
var vehicle_rotation_x: float
var vehicle_rotation_y: float
var vehicle_eyes : Marker3D
## Link objects
var vehicle: VehicleBody3D
var gimbal_inner: Node3D
var camera: Camera3D
var logs: RichTextLabel

var stop = false

func _ready() -> void:
	logs = $"../UI/MarginContainer/VBoxContainer/Info/Logs"
	vehicle = $"../Vehicle"
	vehicle_eyes = $"../Vehicle/Eyes"
	gimbal_inner = $GimbalInner
	## @HACK initial rotation 
	gimbal_inner.rotation = Vector3(0, PI, 0)
	camera = $GimbalInner/Camera3D
	zoom = 1
	zoom_z_position = camera.position.z
	zoom_z_position_min = camera.position.z
	zoom_z_position_max = camera.position.z + zoom_z_position_step * (
		(zoom_max - zoom_min) / zoom_speed
	)
	camera.fov = camera_FOV
	gimbal_offset = Vector3.UP * 1.5
	gimbal_rotation_x = gimbal_inner.rotation.x
	gimbal_rotation_y = gimbal_inner.rotation.y
	gimbal_rotation_z = gimbal_inner.rotation.z
	

func _input(event):
	if event.is_action_pressed("cam_zoom_in"):
		zoom -= zoom_speed
		zoom_z_position -= zoom_z_position_step
	if event.is_action_pressed("cam_zoom_out"):
		zoom += zoom_speed
		zoom_z_position += zoom_z_position_step
	zoom = clamp(zoom, zoom_min, zoom_max)
	zoom_z_position = clamp(
		zoom_z_position, zoom_z_position_min, zoom_z_position_max)
		
func _process(delta):
	## Zoom is modified by player's keyboard/mouse
	var tween_zoom = get_tree().create_tween()
	tween_zoom.tween_property(camera, "position", 
		Vector3(camera.position.x, camera.position.y, zoom_z_position),
		delta * tween_speed)
	var tween_fov = get_tree().create_tween()
	tween_fov.tween_property(camera, "fov", 
		camera_FOV * zoom, delta * tween_speed)
	## Gimbal follow the car position
	var tween_position = get_tree().create_tween()
	tween_position.tween_property(self, "position", 
		vehicle.position + gimbal_offset, delta * tween_follow_speed)
	vehicle_rotation_x = vehicle.rotation.x
	vehicle_rotation_y = vehicle.rotation.y

	## Remember Gimbal rotation
	var new_rotation = Vector3(gimbal_rotation_x + vehicle_rotation_x,
			gimbal_rotation_y + vehicle_rotation_y, gimbal_rotation_z)
			
	## @BAD Jumping Camera rotation when y=360+n
	#tween_rotation.tween_property(gimbal_inner, "rotation", new_rotation, 
	#delta * tween_speed)
	## @GOOD Fix Camera rotation jump when when y=360+n
	var current_rotation_y = gimbal_inner.rotation.y
	var target_rotation_y = new_rotation.y
	var r_delta_y = target_rotation_y - current_rotation_y
	var s_delta_y = wrapf(r_delta_y, -PI, PI)
	var tween_rotation = get_tree().create_tween()
	tween_rotation.tween_property(
		gimbal_inner, "rotation", 
		Vector3(new_rotation.x, 
			current_rotation_y + s_delta_y, 
			new_rotation.z), 
		delta * tween_speed)
		
	## Apply Gimbal rotation
	
	logs.text = \
	"camera.position:" + var_to_str(camera.position) + "\n" + \
	"camera.rotation:" + var_to_str(camera.rotation) + "\n" + \
	"camera.global_position:" + var_to_str(camera.global_position) + "\n" + \
	"camera.global_rotation:" + var_to_str(camera.global_rotation)
		
func logstop(v) -> void:
	if not stop:
		logs.text = var_to_str(v)
		stop = true
