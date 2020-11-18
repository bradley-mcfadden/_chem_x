extends MarginContainer

onready var goal_panel = preload("res://GoalPanel.tscn")
onready var goal_dict := {}

func set_goals(goals):
	# goal is a dict of this form
	# item_id: str
	# rate:    float
	for goal in goals:
		var item = Global.get_item(goal['item_id'])
		var gp = goal_panel.instance()
		$HBoxContainer/VBoxContainer.add_child(gp)
		goal_dict['item_id'] = gp
		gp.set_rate(goal['rate'])
		gp.set_icon(load(item['icon']))
		gp.rect_min_size.x = $HBoxContainer/VBoxContainer/PanelContainer.rect_min_size.x

func update_production(item_id, new_value):
	print('update_production ', item_id, ' ', new_value)
	goal_dict['item_id'].set_current_rate(new_value)
