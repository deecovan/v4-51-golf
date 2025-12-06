extends CanvasLayer

var logs: RichTextLabel
var help: Label
var PFG: Control 
var message: Label
var speedometer_label: Label

func _ready() -> void:
	logs = $MarginContainer/VBoxContainer/Info/Logs
	help = $MarginContainer/Help
	PFG = $MarginContainer/VBoxContainer/PFG
	message = $Message
	speedometer_label = $MarginContainer/VBoxContainer/Speedometer/Label

func _process(_delta: float) -> void:
	help.text = (str(Engine.get_frames_per_second())
		+ ' fps [F1] help [F5] restart scene [F6] debug view [F7] next scene')

func call_draw_curve(curve: Array):
	if not PFG:
		PFG = $MarginContainer/VBoxContainer/PFG
	var draw_node = PFG
	draw_node.curve_array = curve
	draw_node.queue_redraw()

func show_message(text):
	if not message:
		message = $Message
	message.text = text
	message.show()
	await get_tree().create_timer(2.5).timeout
	message.hide()
	
func show_message_again():
	message.text = ''
	message.show()
	await get_tree().create_timer(5).timeout
	message.hide()
	
func hide_info() -> void:
	logs.hide()
	
func show_info() -> void:
	logs.show()
	
func set_speedometer_label(text) -> void:
	speedometer_label.text = text
	
func logs_get() -> RichTextLabel:
	logs = $MarginContainer/VBoxContainer/Info/Logs
	return logs
	
func logs_clr_text() -> void:
	$MarginContainer/VBoxContainer/Info/Logs.text = ""
	
func logs_add_text(text) -> void:
	$MarginContainer/VBoxContainer/Info/Logs.text += text
	
func logs_ins_text(text) -> void:
	$MarginContainer/VBoxContainer/Info/Logs.text = text +\
			$MarginContainer/VBoxContainer/Info/Logs.text
