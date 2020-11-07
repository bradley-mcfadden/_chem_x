extends VBoxContainer
# class_name AccordionButton

signal expanded(num)

export var spacing = 3

var show_space = true

func _init(text, icon):
	$Button.text = text
	$Button.icon = icon

func _ready():
	show_space = !show_space
	if not show_space:
		add_constant_override("separation", 0)
	else:
		add_constant_override("separation", spacing)
	get_parent().update()

func adjust_spacing():
	print(rect_min_size)
	print($Button.rect_min_size)
	show_space = !show_space
	if not show_space:
		add_constant_override("separation", 0)
	else:
		add_constant_override("separation", spacing)

func set_group(gr):
	$Button.group = gr

func _on_Button_pressed():
	print('expanded')
	emit_signal("expanded", 0)


func _on_Button_toggled(button_pressed):
	print('toggled')
