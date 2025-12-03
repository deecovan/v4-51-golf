extends Node

var UI: CanvasLayer
var front_slip_bar: HBoxContainer
var rear_slip_bar: HBoxContainer
var wheel_fl = VehicleWheel3D
var wheel_fr = VehicleWheel3D
var wheel_rl = VehicleWheel3D
var wheel_rr = VehicleWheel3D
var sleep_fl_bar = ProgressBar
var sleep_fr_bar = ProgressBar
var sleep_rl_bar = ProgressBar
var sleep_rr_bar = ProgressBar

func _ready() -> void:
	wheel_fl = $"../Wheel3Dfl"
	wheel_fr = $"../Wheel3Dfr"
	wheel_rl = $"../Wheel3Drl"
	wheel_rr = $"../Wheel3Drr"
	var root = get_tree().get_root().get_child(0)
	var find_UI = root.find_children("UI")
	UI = find_UI[0]
	var find_sleep_fl = UI.find_children("SleepFL")
	var find_sleep_fr= UI.find_children("SleepFR")
	var find_sleep_rl = UI.find_children("SleepRL")
	var find_sleep_rr= UI.find_children("SleepRR")
	sleep_fl_bar = find_sleep_fl[0]
	sleep_fr_bar = find_sleep_fr[0]
	sleep_rl_bar = find_sleep_rl[0]
	sleep_rr_bar = find_sleep_rr[0]

func _physics_process(delta: float) -> void:
	sleep_fl_bar.set_value(wheel_fl.get_skidinfo() * 100.0)
	sleep_fr_bar.set_value(wheel_fr.get_skidinfo() * 100.0)
	sleep_rl_bar.set_value(wheel_fl.get_skidinfo() * 100.0)
	sleep_rr_bar.set_value(wheel_fr.get_skidinfo() * 100.0)
