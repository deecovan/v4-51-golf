extends Control

var min_deg = -135.0
var med_deg =    0.0
var max_deg =  135.0

var max_tac: float

func rotate_speed_pt(rad: float) -> void:
	$SpeedPT.rotation = rad

func rotate_speed_ps(rad: float) -> void:
	$SpeedPS.rotation = rad
	
func get_speed_ps() -> float:
	return $SpeedPS.rotation
	
func get_tach_ps() -> float:
	return $TachoPS.rotation

func rotate_tacho_pt(rad: float) -> void:
	$TachoPT.rotation = rad

func rotate_tacho_ps(rad: float) -> void:
	$TachoPS.rotation = rad
	
func get_min_rad() -> float:
	return deg_to_rad(min_deg)
	
func get_max_rad() -> float:
	return deg_to_rad(max_deg)
	
func get_med_rad() -> float:
	return deg_to_rad(med_deg)
	
func get_max_spd() -> float:
	return 240.0
	
func set_max_tac(t: float) -> void:
	max_tac = t
	
func get_max_tac() -> float:
	return max_tac
	
func get_max_rot() -> float:
	return 1800.0
	
func get_max_dev() -> float:
	return 100
