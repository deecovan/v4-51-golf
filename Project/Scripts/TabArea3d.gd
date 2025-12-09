extends Area3D

var lap_timer_node
var lap_timer_started = false
var lap_timer = 0.0

func _ready() -> void:
	lap_timer_node = $Tab.find_children("LastTime")[0]

func _on_body_entered(body: Node3D) -> void:
	if body is VehicleBody3D:
		lap_timer_node.text == lap_timer
		lap_timer_started = true
		lap_timer = 0.0
			
func _physics_process(delta: float) -> void:
	if lap_timer_started:
		lap_timer += delta
