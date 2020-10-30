extends CanvasLayer

# Manages the GUI layers for various machines
func _on_World_machine_clicked(machine, request):
	match request:
		"RECIPE":
			print('RECIPE')
			$RecipeMenu.connect("recipe_selected", machine, "set_current_recipe")
			$RecipeMenu.current_machine = machine
			$RecipeMenu.visible = true
		"ITEM":
			print('ITEM')
			$ItemMenu.connect("item_selected", machine, "set_current_item")
			$ItemMenu.current_machine = machine
			$ItemMenu.visible = true
		_:
			print('I am confused ', request)
