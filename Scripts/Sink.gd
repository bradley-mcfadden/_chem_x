extends "res://Scripts/PlaceableItem.gd"

# class_name Sink

signal input_response(accept)
signal clicked(machine, request)
signal connect_request(machine)

# Slots
# check_input(item)
# push_to_inventory(item)
# check_output_response

onready var placed:bool = false
onready var count:int = 0
onready var timer := $Timer

var inventory:Queue
var current_item:Dictionary

export var input_dir:int = Constants.Direction.NORTH
export var output_dir:int = -1
export var process_time:int = 1
export var starting_item_id := ''

func _ready():
	._ready()
	timer = $Timer
	timer.wait_time = process_time
	if not starting_item_id == '':
		set_current_item(Global.get_item(starting_item_id))
	make_structure()
	_start()
	place()
	$Button.visible = false

func _start():
	timer.start()

func set_current_item(item):
	current_item = item
	$Contents.texture = load(item['icon'])

func place():
	placed = true
	$Button.visible = true

func push_to_inventory(_item):
	yield(get_tree().create_timer(process_time),"timeout")
	count += 1

func check_input(item):
	if not Global.play_state == Global.MODE.PLAY:
		return
	if not current_item:
		return
	if item['id'] == current_item['id']:
		emit_signal("input_response", true)
	else:
		emit_signal("input_response", false)

func get_count():
	return count

func connect_to_machine(machine):
	print("connected ", self, " to ", machine)
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
