extends "res://Scripts/PlaceableItem.gd"

signal input_response(accept)

# Slots
# check_input(item)
# push_to_inventory(item)
# check_output_response

var timer:Timer
var inventory:Queue
var count:int 

export var input_dir:int = Constants.Direction.NORTH
export var process_time:int = 1

func _ready():
	timer = $Timer
	timer.wait_time = process_time
	timer.start()
	count = 0

func push_to_inventory(item):
	print(self, " ", count)
	count += 1
	pass

func check_input(item):
	print(self, " checking input ", item, " ", count)
	if true:
		emit_signal("input_response", true)
	else:
		emit_signal("input_response", false)

func connect_to_machine(machine):
	print("connected ", self, " to ", machine)
# warning-ignore:return_value_discarded
	connect("output_ready", machine, "check_input")
	machine.connect("input_response", self, "check_output_response")
# warning-ignore:return_value_discarded
	connect("pass_item", machine, "push_to_inventory")

