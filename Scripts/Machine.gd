extends "res://Scripts/PlaceableItem.gd"

signal output_ready(item)
signal pass_item(item)
signal input_response(accept)

# Slots
# check_input(item)
# check_output_response
# push_to_inventory(item)

var timer:Timer
var mutex:Mutex
var inventory:Queue

export var input_dir:int = Constants.Direction.NORTH
export var output_dir:int = Constants.Direction.SOUTH
export var process_time:int = 1
export var items:Array = []
export var capacity:int = 10

func _ready():
	timer = $Timer
	timer.wait_time = process_time
	timer.start()
	inventory = Queue.new(capacity)
	for i in items:
		inventory.push(i)
	print(inventory)
		
func push_to_inventory(item):
	inventory.push(item)
	print(self, ' push_to_inventory ', item, ' ', inventory)

func check_input(item):
	print(self, " checking input ", item, " ", inventory)
	if inventory.is_full():
		emit_signal("input_response", true)
	else:
		emit_signal("input_response", false)

func check_output():
	print(self, not inventory.is_empty())
	if inventory.is_empty():
		var item = inventory.peek()
		print(self, " check_output ", item, " inventory_size ", inventory)
		emit_signal("output_ready", item)

func check_output_response(accept:bool):
	if accept:
		var item = inventory.pop()
		print(self, " check_output_response ", item, " ", inventory)
		emit_signal("pass_item", item)

func connect_to_machine(machine):
	print("connected ", self, " to ", machine)
# warning-ignore:return_value_discarded
	connect("output_ready", machine, "check_input")
	machine.connect("input_response", self, "check_output_response")
# warning-ignore:return_value_discarded
	connect("pass_item", machine, "push_to_inventory")
