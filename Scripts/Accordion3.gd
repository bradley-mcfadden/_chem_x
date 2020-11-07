extends Control

export var spacing = 3
var show_space = false

func _ready():
	$Panel/VBoxContainer.add_constant_override("separation", spacing)
	# add_item('my name is Bradley', load("res://Assets/Items/water_small.png"))
	add_constant_override("separation", spacing)

func _draw():
	var last_end_achor = Vector2.ZERO
	for child in get_children():
		child.rect_position = last_end_achor
		last_end_achor.y = child.rect_position.y + child.rect_size.y 

	rect_min_size.y = last_end_achor.y #to work with ScrollContainer
	# print(rect_min_size)

func expand():
	# print(get_parent.)
	$Panel.expand()
	show_space = !show_space
	if not show_space:
		get_parent().add_constant_override("separation", 0)
	else:
		get_parent().add_constant_override("separation", spacing)

func add_item(txt, icon):
	var label := Button.new()
	label.focus_mode = Control.FOCUS_NONE
	label.align = Button.ALIGN_LEFT
	# label.disabled = true
	label.add_font_override("font", load("res://Fonts/vt323_20.tres"))
	$Panel/VBoxContainer.add_child(label)
	print('help')
	label.text = txt
	label.icon = icon
	print(label.text)
	$Panel.calculate_panel_size()
	# label.text = 'hello'
