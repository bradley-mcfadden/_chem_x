extends "res://Scripts/PlaceableItem.gd"

signal output_ready(item)
signal pass_item(item)
signal input_response(accept)

signal clicked(machine, menu)
signal connect_request(machine)

# Slots
# check_input(item)
# check_output_response
# push_to_inventory(item)

var timer:Timer
var mutex:Mutex
var inventory:Queue
onready var placed:bool = false

export var output_dir:int = Constants.Direction.SOUTH
export var process_time:float = 1.0
export var items:Array = []
export var capacity:int = 10

func _ready():
	timer = $Timer
	timer.wait_time = process_time
	# timer.start()
	inventory = Queue.new(capacity)
	for i in items:
		inventory.push(i)
	$Button.visible = false
	# $Label.text(str(self))

func _start():
	timer.start()

func push_to_inventory(item):
	if not inventory.is_full():
		# yield(get_tree().create_timer(process_time),"timeout")
		inventory.push(item)

func check_input(item):
	if item and inventory.is_full() and item is Dictionary:
		emit_signal("input_response", true)
	else:
		print(self, ' DENIED INPUT')
		emit_signal("input_response", false)

func check_output():
	if not Global.play_state == Global.MODE.PLAY:
		return false
	if inventory.is_empty():
		var item = inventory.peek()
		emit_signal("output_ready", item)

func check_output_response(accept:bool):
	# print(inventory._to_string())
	if accept:
		# print(self, ' passing ', item)
		var item = inventory.pop()
		# print(self, ' passing ', item)
		if not item:
			return
		emit_signal("pass_item", item)

func connect_to_machine(machine):
	# print("connected ", self, " to ", machine)
# warning-ignore:return_value_discarded
	# print('Connected ', self, ' to ', machine)
	connect("output_ready", machine, "check_input")
	machine.connect("input_response", self, "check_output_response")
# warning-ignore:return_value_discarded
	connect("pass_item", machine, "push_to_inventory")

func make_structure():
	.make_structure()
	$Button.disabled = false

func set_current_recipe(_recipe):
	pass

func set_current_item(_item):
	pass

func place():
	placed = true
	$Button.visible = true

func _on_Button_pressed():
	# print(Global.click_state)
	match Global.click_state:
		Global.CLICK_MODE.NORMAL:
			emit_signal("clicked", self, 'RECIPE')
		Global.CLICK_MODE.CONNECT:
			emit_signal("connect_request", self)
