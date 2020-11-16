extends CanvasLayer

# Manages the GUI layers for various machines
func _on_World_machine_clicked(machine, request):
	match request:
		"RECIPE":
			# print('RECIPE')
			get_child(1).connect("recipe_selected", machine, "set_current_recipe")
			get_child(1).current_machine = machine
			get_child(1).visible = true
			# $RecipeAccordionMenu.connect("recipe_selected", machine, "set_current_recipe")
			# $RecipeAccordionMenu.current_machine = machine
			# $RecipeAccordionMenu.visible = true
		"ITEM":
			# print('ITEM')
			$ItemMenu.connect("item_selected", machine, "set_current_item")
			$ItemMenu.current_machine = machine
			$ItemMenu.visible = true
		_:
			print('I am confused ', request)
