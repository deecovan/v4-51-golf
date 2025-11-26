extends CanvasLayer

func show_message(text):
	$Message.text = text
	$Message.show()
	await get_tree().create_timer(2).timeout
	$Message.hide()
