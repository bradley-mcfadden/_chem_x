extends MarginContainer

signal close_signal()


func _on_Button_pressed():
	emit_signal("close_signal")
