extends Node3D

@export var DEBUG = true
var UI: CanvasLayer
var scene: Node3D
var access: FileAccess
var Scenes = [
	"res://Scenes/Main/MainSpaScene.tscn",
	"res://Scenes/Main/MainCupScene.tscn",
	"res://Scenes/Main/MainH3CupScene.tscn",
	"res://Scenes/Main/MainHyperCupScene.tscn",
	"res://Scenes/Main/MainHyperThorusScene.tscn"
	]
var current_scene = 0

func _ready():
	var loader = get_tree().get_root().get_child(0)
	UI = loader.get_node("UI")
	if DEBUG:
		var viewport = get_viewport()
		## Use unshaded for tests
		viewport.debug_draw = viewport.DEBUG_DRAW_UNSHADED
	scene = load_new_scene(0)
	
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.is_echo():
		if scene.is_in_group('Scenes'):
			use_main_controls(event)

func use_main_controls(_event) -> void:
	if Input.is_action_just_pressed('help'):
		UI.show_message_again()
	if Input.is_action_just_pressed('Show Info'):
		UI.show_info()
	if Input.is_action_just_pressed('Hide Info'):
		UI.hide_info()
	if Input.is_action_just_pressed('reload'):
		UI.show_message("Reloading...")
		await get_tree().create_timer(1).timeout
		scene.get_tree().reload_current_scene()
	## Change fullscreen (ONLY if Project Propery Run Windowed)
	if Input.is_action_just_pressed('screen'):
		var mode := DisplayServer.window_get_mode()
		var is_window: bool = mode != DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN \
			if is_window else DisplayServer.WINDOW_MODE_WINDOWED)
	## Toggle between debug draw modes using a key press
	if Input.is_action_just_pressed('viewport'):
		var viewport = get_viewport()
		viewport.debug_draw = (viewport.debug_draw + 1) \
			% 6
	## Change Main scene
	if Input.is_action_just_pressed('next_scene'):
		next_scene()
		
func load_new_scene(scene_id:int) -> Node3D:
	var new_scene = load(Scenes[scene_id]).instantiate()
	new_scene.name = "Scene"
	new_scene.add_to_group("Scenes")
	get_tree().current_scene.call_deferred("add_child",new_scene)
	return(new_scene)

func next_scene() -> void:
	UI.show_message("Called Next scene...")
	scene.queue_free()
	current_scene += 1
	scene = load_new_scene(current_scene)
	
func reload_scene(message):
	UI.show_message(message)
	await get_tree().create_timer(3).timeout
	scene.call_deferred("reload_current_scene")
	
