extends MarginContainer

signal recipe_selected(recipe)

onready var accordion := $VBoxContainer/AccordionScrollArea
onready var menu_idx_mapping := {}
onready var current_machine = null

func _ready():
	# For each recipe, initialize then menu with it
	var i = 0
	for recipe in Global.get_recipe_table():
		# Map recipe to index of menu
		menu_idx_mapping[i] = recipe
		var item = Global.get_item(recipe['id'])
		var tokens = item['name'].split(' ')
		var words = ''
		for word in tokens:
			words += (word[0].to_upper() + word.substr(1)) + ' '
		name = ' ' + words + '(' + str(recipe['quantity']) + ')'
		# Add a new submenu for the recipe
		var acc = accordion.add_new_menu(name, load(item['icon'])).get_accordion()
		# For each ingredient of the recipe, add a menu item
		for comp in recipe['ingredients']:
			var it = Global.get_item(comp['id'])
			var wds = ''
			for word in it['name'].split('_'):
				wds += (word[0].to_upper() + word.substr(1)) + ' ' 
			var nm = ' ' + wds + '(' + str(comp['quantity']) + ')'
			acc.add_item(nm, load(it['icon']))
		acc.add_item("   Crafting Speed: " + str(recipe['speed']), null)
		i += 1

# When item is selected, return a recipe
func _on_ItemList_item_selected(index):
	if index < 1:
		return
	emit_signal("recipe_selected", menu_idx_mapping[index])

func _on_Close_pressed():
	self.visible = false
	disconnect_from_machine()

# Set recipe on machine, close menu, disconnect machine
func _on_OK_pressed():
	var idx = accordion.get_selected()
	if idx == -1:
		return
	self.visible = false
	emit_signal("recipe_selected", menu_idx_mapping[idx])
	disconnect_from_machine()

func disconnect_from_machine():
	if current_machine.has_method("set_current_recipe"):
		disconnect("recipe_selected", current_machine, "set_current_recipe")
