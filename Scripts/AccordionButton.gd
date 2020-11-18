extends VBoxContainer

class_name AccordionButton

signal expanded(button)

export var spacing = 3

var show_space = true
var button_state = false

func _ready():
	print(self)
	show_space = !show_space
	if not show_space:
		add_constant_override("separation", 0)
	else:
		add_constant_override("separation", spacing)
	# $Button.connect("pressed", self, "_on_Button_pressed")

func set_selected(selected:bool):
	$Button.pressed = selected

func is_selected():
	return button_state

func get_accordion():
	return $Accordion3

func set_group(grp):
	$Button.group = grp

func set_icon(icon):
	$Button.icon = icon

func set_text(text):
	$Button.text = text

func _on_Button_pressed():
	emit_signal("expanded")

func _on_Button_toggled(button_pressed):
	button_state = button_pressed
