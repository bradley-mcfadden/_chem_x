extends Node2D
var child_ids:Array
var loaded_children:Array

func _ready():
	# self.get_loaded_children()
	pass

func child_by_index(index):
	if index < len(loaded_children) and index >= 0:
		return loaded_children[index]

func get_loaded_children() -> Array:
	for c in self.get_children():
		var dict = {
			'resource' : load(c.filename),
			'name'     : c.name,
			'texture'  : c.get_child(0).texture.duplicate()
		}
		loaded_children.append(dict)
	return loaded_children
