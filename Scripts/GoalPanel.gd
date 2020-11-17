extends CenterContainer

# class_name GoalPanel

var icon:Resource = null
var rate:float = 0.0

onready var tx_rect := $Panel/MarginContainer/VBoxContainer2/HBoxContainer/TextureRect
onready var curr_label := $Panel/MarginContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Label
onready var rate_label := $Panel/MarginContainer/VBoxContainer2/HBoxContainer/VBoxContainer/Label2

#func _init(_icon, _rate):
#	icon = _icon
#	rate = _rate

func _ready():
	tx_rect.texture = icon
	curr_label.text = '0.0/s'
	rate_label.text = '/' + str(rate)

func set_icon(icon):
	tx_rect.texture = icon

func set_rate(rate):
	rate_label.text = '/' + str(rate)

func set_current_rate(_curr_rate):
	curr_label.text = str(round(_curr_rate * 10) / 10) + '/s'
