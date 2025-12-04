extends Node

@onready var _timer = $"../Timer"
@onready var _start = $"../Start"
@onready var _idle = $"../Idle"
@onready var _pow = $"../Pow"
var vehicle
var vel
var power
var max_s
var max_p
var snd_start
## Sound Scale from velocity, Volume from power
var scale
var vol

func _ready():
	vehicle = $".."
	max_s = vehicle.MAX_SPEED
	max_p = vehicle.MAX_POWER
	snd_start = max_s / 32
	_pow.volume_db = -32.0
	_timer.connect("timeout", on_timer_timeout)
	_start.play()
	_timer.start()
	
func _physics_process(_delta: float) -> void:
	vel = vehicle.linear_velocity.length()
	power = vehicle.engine_force
	scale = 1 + vel / max_s
	vol = power / max_p
	if not _start.playing and not _idle.playing:
		_idle.play()
	if not _start.playing and not _pow.playing:
		_pow.play()
	if vel > snd_start:
		_idle.pitch_scale = scale
		_pow.pitch_scale = scale
		_pow.volume_db = vol * 32 - 32
	## Randomise loops
	if randf() > 0.9: _idle.play()
	if randf() > 0.9: _pow.play()

func on_timer_timeout():
	_start.stop()
	_idle.play()
