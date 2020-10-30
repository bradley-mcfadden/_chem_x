extends "res://Scripts/PlaceableItem.gd"

export var type:PackedScene = load("res://Scenes/Entity.tscn") setget set_type
export var count:int = 5000

func get_item():
	if count > 0:
		count -= 1
		return type.instance()

func set_type(new_type):
	print('In setter')
	type = new_type
	var text = new_type.instance().texture
	print(type)
