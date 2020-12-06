extends MarginContainer

signal closed()


func _on_Button_pressed():
	emit_signal("closed")
