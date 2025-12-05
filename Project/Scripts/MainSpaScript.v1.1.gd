extends Node3D

var find: Array
var vehicle: VehicleBody3D
var UI: CanvasLayer

func _ready():
	vehicle = find_child("Vehicle")
	UI = get_parent().find_child("UI")
	UI.show_message("Spa Flat Ready!")

func _process(_delta):
	if Input.is_action_just_pressed('restore'):
		UI.show_message("Restoring...")
		vehicle.position.y = vehicle.position.y + 1
		vehicle.position = Vector3(
			vehicle.position.x + randf() * 2.0 - 1.0,
			vehicle.position.y + 2.0,
			vehicle.position.z +  randf() * 2.0 - 1.0)
		vehicle.rotation = Vector3.ZERO
		vehicle.constant_force = Vector3.ZERO
		vehicle.constant_torque = Vector3.ZERO
