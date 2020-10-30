extends "res://Scripts/Machine.gd"

var current_recipe:Dictionary
onready var item_counts:Dictionary = {}

func set_current_recipe(recipe):
	print('SET RECIPE TO', recipe)
	current_recipe = recipe
	var item = Global.get_item(recipe['id'])
	item_counts.clear()
	for k in recipe['ingredients']:
		item_counts[k['id']] = 0
	$Contents.texture = load(item['icon'])

func check_input(item):
	# print(self, " checking input ", item, " ", inventory)
	if not current_recipe:
		return
	print('checking input')
	var found_flag = false
	for ingr in current_recipe['ingredients']:
		if item['id'] == ingr['id']:
			found_flag = true
			break 
	if found_flag:
		emit_signal("input_response", true)
		print('approved input')
	else:
		emit_signal("input_response", false)
		print('denied input')

func push_to_inventory(item):
	# item.set_lerp_target(self.global_position, process_time)
	# print('before yield')
	# yield(get_tree().create_timer(process_time),"timeout")
	# print('after yield')
	item_counts[item['id']] += 1

func check_output():
	if not Global.play_state == Global.MODE.PLAY:
		return
	if not current_recipe:
		return
	var item = current_recipe
	var craftable = true
	for ingr in current_recipe['ingredients']:
		if item_counts[ingr['id']] < ingr['quantity']:
			craftable = false
			break
	if craftable:
		emit_signal("output_ready", item)

func check_output_response(accept:bool):
	if accept:
		print("ACCEPTED")
		$AnimatedSprite.animation = "active"
		$Bubbles.play()
		yield(get_tree().create_timer(current_recipe['speed']),"timeout")
		$AnimatedSprite.animation = "idle"
		$Bubbles.stop()
		for k in current_recipe.keys():
			for ingr in current_recipe['ingredients']:
				if k == ingr['id']:
					item_counts -= ingr['quantity']
					break
		var item = Global.get_item(current_recipe['id'])
		emit_signal("pass_item", item)
