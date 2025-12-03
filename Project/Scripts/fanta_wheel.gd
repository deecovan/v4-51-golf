extends Node

@export var sleep_start = 0.2

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

func _physics_process(_delta: float) -> void:
	sleep_fl_bar.set_value(val_sleep(wheel_fl))
	sleep_fr_bar.set_value(val_sleep(wheel_fr))
	sleep_rl_bar.set_value(val_sleep(wheel_rl))
	sleep_rr_bar.set_value(val_sleep(wheel_rr))

func val_sleep(target: VehicleWheel3D) -> float:
	var val = target.get_skidinfo()
	if val < sleep_start: 
		play_sleep(target, (sleep_start / val))
	else: stop_sleep(target)
	return 10.0 - val * 100.0
	
func play_sleep(target: VehicleWheel3D, volume: float) -> void:
	var find_target_player = target.find_children("AudioStreamPlayer3D")
	var target_player: AudioStreamPlayer3D = find_target_player[0]
	target_player.volume_db = volume * 20 - 40
	if (!target_player.playing): target_player.play()

func stop_sleep(target: VehicleWheel3D) -> void:
	var find_target_player = target.find_children("AudioStreamPlayer3D")
	var target_player: AudioStreamPlayer3D = find_target_player[0]
	target_player.stop()
	pass
