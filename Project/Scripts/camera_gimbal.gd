extends Node3D

## Keyboard controlled Rotation and Zoom
@export var zoom_speed = 0.1
@export var camera_speed = PI / 2
@export var camera_FOV = 60
@export var zoom = 1.0
## Tween larger values to slow down
@export var tween_speed = 8.0
@export var tween_follow_speed = 4.0
## Mouse controlled Rotation sensivity and direction
@export var mouse_sensivity = 5000
## -1 normal or +1 inversed
@export var mouse_direction = -1
var gimble_offset: Vector3
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

func _ready() -> void:
	vehicle = $"../Vehicle"
	vehicle_eyes = $"../Vehicle/Eyes"
	gimbal_inner = $GimbalInner
	camera = $GimbalInner/Camera3D
	zoom = 1
	camera.fov = camera_FOV
	gimble_offset = Vector3.UP * 1.5
	gimbal_rotation_x = gimbal_inner.rotation.x
	gimbal_rotation_y = gimbal_inner.rotation.y
	gimbal_rotation_z = gimbal_inner.rotation.z

func _input(event):
	if event.is_action_pressed("cam_zoom_in"):
		zoom -= zoom_speed
	if event.is_action_pressed("cam_zoom_out"):
		zoom += zoom_speed
		
func _process(delta):
	## Zoom is modified by player's keyboard
	var tween_scale = get_tree().create_tween()
	tween_scale.tween_property(camera, "fov", 
		camera_FOV * zoom, delta * tween_speed)
	## Gimbal follow the car position
	var tween_position = get_tree().create_tween()
	tween_position.tween_property(self, "position", 
		vehicle.position + gimble_offset, delta * tween_follow_speed)
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

	## Apply Gimbal rotation
	## Fix Camera rotation jump near y~=0
	var new_rotation = Vector3(gimbal_rotation_x + vehicle_rotation_x,
			gimbal_rotation_y + vehicle_rotation_y, gimbal_rotation_z)
	if new_rotation.y > PI: new_rotation.y -= 2*PI
	if gimbal_inner.rotation.y > PI: gimbal_inner.rotation.y -= 2*PI
	if new_rotation.y < 0: new_rotation.y += 2*PI
	if gimbal_inner.rotation.y < 0: gimbal_inner.rotation.y += 2*PI
	print(var_to_str(new_rotation - gimbal_inner.rotation))
	
	var tween_rotation = get_tree().create_tween()
	tween_rotation.tween_property(gimbal_inner, "rotation", new_rotation, 
	delta * tween_speed)
	gimbal_inner.rotation.x = gimbal_rotation_x + vehicle_rotation_x
	gimbal_inner.rotation.y = gimbal_rotation_y + vehicle_rotation_y
		
	## Camera is always looking at Vehicle/Eyes marker
	camera.look_at(vehicle.global_position + gimble_offset)
