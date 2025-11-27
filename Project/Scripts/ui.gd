extends CanvasLayer

func call_draw_curve(curve: Array):
	var draw_node = $MarginContainer/VBoxContainer/Draw
	draw_node.curve_array = curve
	draw_node.queue_redraw()

func show_message(text):
	$Message.text = text
	$Message.show()
	await get_tree().create_timer(2).timeout
	$Message.hide()
