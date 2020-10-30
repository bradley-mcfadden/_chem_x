extends MarginContainer

# In some machine, show this menu after being clicked
# Connect machine's set_recipe slot to recipe selected
# After ESC pressed, disconnect from machine and hide

signal recipe_selected(recipe)

onready var item_list := $VBoxContainer/ItemList
onready var menu_idx_mapping := {}
onready var current_machine = null

func _ready():
	item_list.add_item('Recipe List', null, false)
	#item_list.
	var i := 1
	for recipe in Global.get_recipe_table():
		var item = Global.get_item(recipe['id'])
		var name = str(recipe['quantity']) + 'x ' + item['name']
		var ingredients := ''
		for comp in recipe['ingredients']:
			var temp = Global.get_item(comp['id'])
			ingredients += str(comp['quantity']) + 'x ' + temp['name'] + ', '
		print(ingredients)
		menu_idx_mapping[i] = recipe
		item_list.add_item(name, load(item['icon']), true)
		item_list.set_item_tooltip(i, ingredients)
		# popup.add_icon_radio_check_item(txt, name, i)
		# popup.set_item_tooltip(popup.get_item_count() - 1, ingredients)
		i += 1

func _on_ItemList_item_selected(index):
	if index < 1:
		return
	emit_signal("recipe_selected", menu_idx_mapping[index])

func _on_Close_pressed():
	self.visible = false
	disconnect_from_machine()

func _on_OK_pressed():
	if not item_list.is_anything_selected():
		return
	var index = item_list.get_selected_items()[0]
	self.visible = false
	emit_signal("recipe_selected", menu_idx_mapping[index])
	disconnect_from_machine()

func disconnect_from_machine():
	if current_machine.has_method("set_current_recipe"):
		disconnect("recipe_selected", current_machine, "set_current_recipe")
