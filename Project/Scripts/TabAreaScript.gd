extends Area3D

var lap_timer_started = false
var lap_timer = 0.0
var tab: MeshInstance3D

func _ready() -> void:
	var find = get_parent().find_children("Tab")
	tab = find[0]

func _on_body_entered(body: Node3D) -> void:
	if body is VehicleBody3D:
		if lap_timer_started:
			var current = tab.GetCurrTime()
			var last = tab.GetLastTime()
			var best = tab.GetBestTime()
			var beat = tab.GetBeatTime()
			if best == 0.0 or best > current:
				tab.SetBestTime(current)
				tab.SetBestTimeColor(Color.HOT_PINK)
			else:
				tab.SetBestTimeColor(Color.WHITE)
				
			if beat == 0.0 or beat > current:
				tab.SetBeatTime(current)
				tab.SetBeatTimeColor(Color.HOT_PINK)
			else:
				tab.SetBeatTimeColor(Color.WHITE)
				
			if last == 0.0 or last > current:
				tab.SetLastTimeColor(Color.CHARTREUSE)
			else:
				tab.SetLastTimeColor(Color.WHITE)
			tab.SetLastTime(lap_timer)
			lap_timer = 0.0
		else:
			lap_timer_started = true

func _physics_process(delta: float) -> void:
	if lap_timer_started:
		lap_timer += delta
		tab.SetCurrTime(lap_timer)
