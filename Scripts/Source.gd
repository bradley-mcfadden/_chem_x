extends "res://Scripts/PlaceableItem.gd"

signal output_ready(item)
signal input_response(accept)
signal pass_item(item)

# Slots
# check_input(item)
# check_output_response
# push_to_inventory(item)

var timer:Timer

export var output_dir:int = Constants.Direction.SOUTH
export var process_time:int = 1
export var item:int = 10

func _ready():
	timer = $Timer
	timer.wait_time = process_time
	timer.start()

func check_output():
	print(self, ' check_output ', item)
	emit_signal("output_ready", item)

func check_output_response(accept:bool):
	print(self, " check_output_reponse ", accept)
	if accept:
		emit_signal("pass_item", item)
		item = int(rand_range(10, 20))

func connect_to_machine(machine):
	print("connected ", self, " to ", machine)
# warning-ignore:return_value_discarded
	connect("output_ready", machine, "check_input")
	machine.connect("input_response", self, "check_output_response")
# warning-ignore:return_value_discarded
	connect("pass_item", machine, "push_to_inventory")
