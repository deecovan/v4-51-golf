extends Node

@onready var _timer = $"../Timer"
@onready var _start = $"../Start"
@onready var _idle = $"../Idle"
@onready var _med = $"../Med"
var vehicle
var vel
var max
var power
var max_p
var snd_start
var vol

func _ready():
	vehicle = $".."
	max = vehicle.MAX_SPEED
	max_p = vehicle.MAX_POWER
	snd_start = max / 20
	_med.volume_db = -32.0
	_timer.connect("timeout", on_timer_timeout)
	_start.play()
	_timer.start()
	
func _physics_process(delta: float) -> void:
	vel = vehicle.linear_velocity.length()
	power = vehicle.engine_force
	vol = power / max_p
	if not _start.playing and not _idle.playing:
		_idle.play()
	if not _start.playing and not _med.playing:
		_med.play()
	if vel > snd_start:
		var scale = 1 + vel / max
		_idle.pitch_scale = scale
		_med.pitch_scale = scale
		_med.volume_db = vol * 10 - 10

func on_timer_timeout():
	_start.stop()
	_idle.play()
