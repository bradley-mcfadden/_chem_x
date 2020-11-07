extends MarginContainer

signal recipe_selected(recipe)

onready var accordion := $VBoxContainer/AccordionScrollArea
onready var menu_idx_mapping := {}
onready var current_machine = null

func _ready():
	for i in range(5):
		for recipe in Global.get_recipe_table():
			var item = Global.get_item(recipe['id'])
			var tokens = item['name'].split(' ')
			var words = ''
			for word in tokens:
				words += (word[0].to_upper() + word.substr(1)) + ' '
			name = ' ' + words + '(' + str(recipe['quantity']) + ')'
			var acc = accordion.add_new_menu(name, load(item['icon'])).get_accordion()
			for comp in recipe['ingredients']:
				var it = Global.get_item(comp['id'])
				var wds = ''
				for word in it['name'].split('_'):
					wds += (word[0].to_upper() + word.substr(1)) + ' ' 
				var nm = wds + '(' + str(comp['quantity']) + ')'
				acc.add_item(nm, load(it['icon']))
			acc.add_item("  Crafting Speed: " + str(recipe['speed']), null) 

func _on_ItemList_item_selected(index):
	if index < 1:
		return
	emit_signal("recipe_selected", menu_idx_mapping[index])

func _on_Close_pressed():
	self.visible = false
	disconnect_from_machine()

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
