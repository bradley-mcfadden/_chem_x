extends "res://Scripts/PlaceableItem.gd"

# class_name Source

signal output_ready(item)
# signal input_response(accept)
signal pass_item(item)

signal clicked(machine, request)
signal connect_request(machine)

# Slots
# check_input(item)
# check_output_response
# push_to_inventory(item)

onready var timer := $Timer
onready var placed := false

var current_item:Dictionary

export var output_dir:int = Constants.Direction.SOUTH
export var process_time:int = 1
export var starting_item_id := ''

func _ready():
	timer = $Timer
	timer.wait_time = process_time
	make_structure()
	_start()
	place()
	if not starting_item_id == '':
		set_current_item(Global.get_item(starting_item_id))

func _start():
	timer.start()

func set_current_item(item):
	current_item = item
	$Contents.texture = load(item['icon'])

func place():
	placed = true
	$Button.visible = true


func check_output():
	if not current_item:# or not inventory.is_empty():
		return
	emit_signal("output_ready", current_item)

func check_output_response(accept:bool):
	if accept:
		emit_signal("pass_item", current_item)

func connect_to_machine(machine):
	# warning-ignore:return_value_discarded
	connect("output_ready", machine, "check_input")
	machine.connect("input_response", self, "check_output_response")
	# warning-ignore:return_value_discarded
	connect("pass_item", machine, "push_to_inventory")

func _on_Button_pressed():
	match Global.click_state:
		Global.CLICK_MODE.NORMAL:
			emit_signal("clicked", self, 'ITEM')
		Global.CLICK_MODE.CONNECT:
			emit_signal("connect_request", self)
