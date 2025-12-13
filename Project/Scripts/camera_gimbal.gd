extends Node3D

## Keyboard controlled Rotation and Zoom
@export var camera_speed = PI/3
@export var camera_FOV = PI*10
@export var zoom_min = PI/3
@export var zoom_max = PI
@export var zoom_speed = 1/PI
@export var zoom = PI/1.5
var arm_spring_length: float
var arm_spring_length_min: float
var arm_spring_length_max: float
@export var arm_spring_length_step = 2
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
var camera: Camera3D
var arm: SpringArm3D

var stop = false
var UI = CanvasItem

func _ready() -> void:
	var root = get_tree().get_root().get_child(0)
	UI = root.find_children("UI")[0]
	vehicle = $"../Vehicle"
	arm = $GimbalInner
	## Initial position
	global_position = vehicle.global_position
	rotation = Vector3.ZERO
	## Initial Camera
	arm = $GimbalInner
	camera = $GimbalInner/Camera3D
	## Fix rotation
	arm_spring_length = arm.spring_length
	arm_spring_length_min = arm.spring_length
	arm_spring_length_max = arm.spring_length + arm_spring_length_step * (
		(zoom_max - zoom_min) / zoom_speed
	)
	camera.fov = camera_FOV
	## Initial Mouse Gimbal rotation
	gimbal_rotation_x = arm.rotation.x
	gimbal_rotation_y = arm.rotation.y
	gimbal_rotation_z = arm.rotation.z
	## Initial Camera rotation 
	arm.rotation = Vector3(0, 0, 0)

func _input(event):
	if event.is_action_pressed("cam_zoom_in"):
		zoom -= zoom_speed
		arm_spring_length -= arm_spring_length_step
	if event.is_action_pressed("cam_zoom_out"):
		zoom += zoom_speed
		arm_spring_length += arm_spring_length_step
	zoom = clamp(zoom, zoom_min, zoom_max)
	arm_spring_length = clamp(
		arm_spring_length, arm_spring_length_min, arm_spring_length_max)
	
		
func _process(delta):
	## Zoom is modified by player's keyboard/mouse
	var tween_zoom = get_tree().create_tween()
	tween_zoom.tween_property(arm, "spring_length", 
		arm_spring_length,
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
		gimbal_rotation_x - vehicle_rotation_x,
			gimbal_rotation_y + vehicle_rotation_y, 
			gimbal_rotation_z)

	## @GOOD Fix Camera rotation jump when when y=360+n
	var current_rotation_y = arm.rotation.y
	var target_rotation_y = new_rotation.y
	var r_delta_y = target_rotation_y - current_rotation_y
	var s_delta_y = wrapf(r_delta_y, -PI, PI)
	var tween_rotation = get_tree().create_tween()
	tween_rotation.tween_property(
		arm, "rotation", 
		Vector3(new_rotation.x, 
			current_rotation_y + s_delta_y, 
			new_rotation.z), 
		delta * tween_speed)
