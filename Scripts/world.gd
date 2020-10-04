extends Node2D

var background:TileMap
var player:KinematicBody2D
var current_placeable:int
var current_ghost:Node2D

var placeable_tiles = preload("res://Placeable Scenes/PlaceableItems.tscn")
var structures:Array
var structures_node:Node

export var world_rect:Vector2 = Vector2(30, 20)

func _ready():
	background = $BackgroundTiles
	player = $Player
	structures = placeable_tiles.instance().get_loaded_children()
	structures_node = $BackgroundTiles/Structures
	player.setup_hotbar(structures)
	structures_node.setup_world_size(world_rect)


func _unhandled_input(event):
	if Input.is_action_just_pressed("click"):
		if current_ghost: # and current_ghost.check_space_clear():
			var struct = current_ghost.duplicate()
			structures_node.add_child(struct)
			struct.make_structure()
			match structures[current_placeable]['name']:
				"Belt":
					var map_pos = background.world_to_map(current_ghost.global_position)
					struct.set_facing(current_ghost.get_facing())
					structures_node.add_belt(struct, map_pos.x, map_pos.y)
				"Poller":
					structures_node.add_poller()
				_:
					pass

func _input(event):
	if current_ghost:
		current_ghost.global_position = background.map_to_world(background.world_to_map(get_global_mouse_position()))
		# print(background.world_to_map(current_ghost.global_position))
	if Input.is_action_just_pressed("rotate_item"):
		if current_ghost:
			current_ghost.rotate90()
		else:
			pass
	elif Input.is_action_just_pressed("clear_item"):
		clear_current()
		
func _instance_item(index):
	# print(structures[index])
	clear_current()
	current_placeable = index
	current_ghost = structures[index]["resource"].instance()
	self.add_child(current_ghost)

func clear_current():
	if current_ghost:
		current_placeable = -1
		current_ghost.queue_free()
		current_ghost = null
