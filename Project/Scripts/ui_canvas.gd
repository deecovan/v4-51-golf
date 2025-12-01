extends CanvasLayer

func _process(_delta: float) -> void:
	$MarginContainer/Help.text = (str(Engine.get_frames_per_second())
		+ ' fps [F1] help')

func call_draw_curve(curve: Array):
	var draw_node = $MarginContainer/VBoxContainer/PFG
	draw_node.curve_array = curve
	draw_node.queue_redraw()

func show_message(text):
	$Message.text = text
	$Message.show()
	await get_tree().create_timer(2).timeout
	$Message.hide()
	
func show_message_again():
	$Message.text = ''
	$Message.show()
	await get_tree().create_timer(5).timeout
	$Message.hide()
