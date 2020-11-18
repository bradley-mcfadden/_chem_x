extends MarginContainer

# In some machine, show this menu after being clicked
# Connect machine's set_item slot to item selected
# After close pressed, disconnect from machine and hide

signal item_selected(item)

onready var item_list := $VBoxContainer/ItemList
onready var menu_idx_mapping := {}
onready var current_machine = null

func _ready():
	item_list.add_item('Items', null, false)
	#item_list.
	var i := 1
	for item in Global.get_item_table():
		# var txt = ImageTexture.new()
		# txt.load(item['icon'])
		var wds = ''
		for word in item['name'].split('_'):
			wds += (word[0].to_upper() + word.substr(1)) + ' ' 
		item_list.add_item(' ' + wds, load(item['icon']), i)
		menu_idx_mapping[i] = item
		i += 1

func _on_ItemList_item_selected(index):
	if index < 1:
		return
	emit_signal("item_selected", menu_idx_mapping[index])

func _on_Close_pressed():
	self.visible = false
	item_list.unselect_all()
	disconnect_from_machine()

func _on_OK_pressed():
	if not item_list.is_anything_selected():
		return
	var index = item_list.get_selected_items()[0]
	visible = false
	emit_signal("item_selected", menu_idx_mapping[index])
	item_list.unselect_all()
	disconnect_from_machine()

func disconnect_from_machine():
	if current_machine.has_method("set_current_item"):
		disconnect("item_selected", current_machine, "set_current_item")
