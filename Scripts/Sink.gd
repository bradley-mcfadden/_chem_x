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

var timer:Timer
var inventory:Queue
var current_item:Dictionary

export var input_dir:int = Constants.Direction.NORTH
export var output_dir:int = -1
export var process_time:int = 1
export var starting_item_id := ''

func _ready():
	timer = $Timer
	timer.wait_time = process_time
	# $Button.visible = false
	if not starting_item_id == '':
		set_current_item(Global.get_item(starting_item_id))
	make_structure()
	_start()
	place()

func _start():
	timer.start()

func set_current_item(item):
	current_item = item
	print('SET CURRENT ITEM TO ', item)
	$Contents.texture = load(item['icon'])

func place():
	#print($CanvasLayer.z_index)
	#print($Sprite.z_index)
	placed = true
	$Button.visible = true
#	$CanvasLayer/MenuButton.disabled = false
#	popup = $CanvasLayer/MenuButton.get_popup()
#	# popup.set_as_toplevel(true)
#	# popup.show_on_top = true
#	popup.set_hide_on_checkable_item_selection(false)
#	var i := 0
#	for item in Global.get_item_table():
#		var img = Image.new()
#		img.load(item['icon'])
#		var txt = ImageTexture.new()
#		txt.create_from_image(img)
#		popup.add_icon_radio_check_item(txt, item['name'], i)
#		menu_id_mapping[i] = item
#		i += 1
#	popup.connect("index_pressed", self, "_on_MenuButton_pressed")

func push_to_inventory(item):
	# item.set_lerp_target(self.global_position, process_time)
	print('before yield')
	yield(get_tree().create_timer(process_time),"timeout")
	print('after yield')
	print(self, " ", count)
	count += 1
	print("COUNT", count)
	# item.queue_free()

func check_input(item):
	if not Global.play_state == Global.MODE.PLAY:
		return
	# print(self, " checking input ", item, " ", count)
	if not current_item:
		return
	if item['id'] == current_item['id']:
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

#func _on_MenuButton_pressed(index):
#	print('yes')
#	var checked = popup.is_item_checked(index)
#	popup.set_item_checked(index, not checked)
#	if not checked:
#		for i in range(popup.get_item_count()):
#			print(i)
#			if not i == index:
#				$CanvasLayer/MenuButton.get_popup().set_item_checked(i, checked)
#		print(menu_id_mapping[index])

func _on_Button_pressed():
	# print(Global.click_state)
	match Global.click_state:
		Global.CLICK_MODE.NORMAL:
			emit_signal("clicked", self, 'ITEM')
		Global.CLICK_MODE.CONNECT:
			emit_signal("connect_request", self)
