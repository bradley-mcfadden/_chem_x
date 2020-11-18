extends ScrollContainer

signal item_index_selected(index)
onready var bgroup := ButtonGroup.new()
onready var a_btn := preload('res://Scenes/AccordionButton.tscn')
# func _ready():
# 	add_new_menu('My name is Bradley', null)

func add_new_menu(text, icon):
	var item := preload('res://Scenes/AccordionButton.tscn').instance()
	$VBoxContainer.add_child(item)
	item.set_group(bgroup)
	item.set_text(text)
	item.set_icon(icon)
	item.connect("expanded", self, "_on_Item_expanded")
	# print($VBoxContainer.get_child_count())
	return item

func unselect_all():
	for child in $VBoxContainer.get_children():
		child.set_selected(false)

func get_selected():
	var i = 0
	for child in $VBoxContainer.get_children():
		if child.is_selected():
			return i
		i += 1
	return -1

func get_menu(index):
	return $VBoxContainer.get_child(index)

func _on_Item_expanded(item):
	emit_signal("item_index_selected", item.get_index())
