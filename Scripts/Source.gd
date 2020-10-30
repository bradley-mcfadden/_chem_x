extends "res://Scripts/PlaceableItem.gd"

# class_name Source

signal output_ready(item)
signal input_response(accept)
signal pass_item(item)

signal clicked(machine, request)
signal connect_request(machine)

# Slots
# check_input(item)
# check_output_response
# push_to_inventory(item)

var timer:Timer
#var popup:PopupMenu
#var menu_id_mapping:Dictionary
var current_item:Dictionary

export var output_dir:int = Constants.Direction.SOUTH
export var process_time:int = 1
export var starting_item_id := ''

# export var item:PackedScene = load("res://Scenes/Entity.tscn")

onready var placed := false

func _ready():
	timer = $Timer
	timer.wait_time = process_time
	# $Button.visible = false
	# timer.start()
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
	#print($CanvasLayer.z_index)
	#print($Sprite.z_index)
	placed = true
	$Button.visible = true
#	$MenuButton.disabled = false
#	popup = $MenuButton.get_popup()
#	# popup.set_hide_on_checkable_item_selection(false)
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

func check_output():
	# print(self, ' check_output ', current_item)
	if not current_item:# or not inventory.is_empty():
		return
	emit_signal("output_ready", current_item)

func check_output_response(accept:bool):
	# print(self, " check_output_reponse ", accept)
	if accept:
		#var e = item.instance()
		#add_child(e)
		emit_signal("pass_item", current_item)
		# item = int(rand_range(10, 20))

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
#				$MenuButton.get_popup().set_item_checked(i, checked)
#		print(menu_id_mapping[index])

func _on_Button_pressed():
	# print(Global.click_state)
	match Global.click_state:
		Global.CLICK_MODE.NORMAL:
			emit_signal("clicked", self, 'ITEM')
		Global.CLICK_MODE.CONNECT:
			emit_signal("connect_request", self)
