extends Node3D

## Keyboard controlled Rotation and Zoom
@export var camera_speed = PI/3
@export var camera_FOV = PI*10
@export var zoom_min = PI/3
@export var zoom_max = PI
@export var zoom_speed = 1/PI
var zoom = PI/2
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
	## Initial position
	global_position = vehicle.global_position
	## Initial Gimbal Height
	gimbal_offset = Vector3.UP
	## Initial rotation 
	gimbal_inner.rotation = Vector3(0, PI, 0)
	## Initial Camera
	camera = $GimbalInner/Camera3D
	zoom_z_position = camera.position.z
	zoom_z_position_min = camera.position.z
	zoom_z_position_max = camera.position.z + zoom_z_position_step * (
		(zoom_max - zoom_min) / zoom_speed
	)
	camera.fov = camera_FOV
	## Initial Mouse Gimbal rotation
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

	## Remember Gimbal rotation
	var new_rotation = Vector3(
		gimbal_rotation_x + vehicle_rotation_x + 1/PI - zoom/PI,
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
	
	logs.text = \
	"vehicle.global_position: " + var_to_str(vehicle.global_position) + "\n" + \
	"global_position: " + var_to_str(global_position) + "\n" + \
	"gimbal_inner.rotation: " + var_to_str(gimbal_inner.rotation) + "\n" + \
	"zoom: " + var_to_str(zoom) + "\n" + \
	"zoom_z_position: " + var_to_str(zoom_z_position) + "\n" + \
	"camera.fov: " + var_to_str(camera.fov) + "\n" + \
	"new_rotation: " + var_to_str(new_rotation)
	#logs.text = \
	#"camera.position: " + var_to_str(camera.position) + "\n" + \
	#"camera.rotation: " + var_to_str(camera.rotation) + "\n" + \
	#"camera.global_position: " + var_to_str(camera.global_position) + "\n" + \
	#"camera.global_rotation: " + var_to_str(camera.global_rotation)
	""
func logstop(v) -> void:
	if not stop:
		logs.text = var_to_str(v)
		stop = true
