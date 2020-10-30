extends MenuButton


func _input(event:InputEvent):
	#print(event)
	if Input.is_mouse_button_pressed(1):
		# print('yes')
		show_modal()
