extends VehicleWheel3D

var root: Node

func _ready() -> void:
	root = get_tree().get_root().get_child(0)
	print(var_to_str(root))

func _physics_process(delta: float) -> void:
	pass
