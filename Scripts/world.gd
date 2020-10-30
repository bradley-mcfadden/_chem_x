extends Node2D

signal machine_clicked(machine, request)

var current_placeable:int
var current_ghost:Node2D
var placeable_tiles = preload("res://Placeable Scenes/PlaceableItems.tscn")
var structures:Array

export var world_rect:Vector2 = Vector2(30, 20)

onready var player := $Player
onready var background := $BackgroundTiles
onready var structures_node := $Background/Structures

func _ready():
	structures = placeable_tiles.instance().get_loaded_children()
	player.setup_hotbar(structures)
	structures_node.setup_world_size(world_rect)
	Global.load_items()

func _unhandled_input(_event):
	if Input.is_action_just_pressed("click"):
		if current_ghost and current_ghost.is_placeable == true: # and current_ghost.check_space_clear():
			$Sounds/PlaceBlock.play()
			var struct = current_ghost.duplicate()
			structures_node.add_child(struct)
			struct.make_structure()
			struct.place()
			var map_pos = background.world_to_map(current_ghost.global_position)
			match structures[current_placeable]['name']:
				"Belt_A":
					print('yes, adding a Belt_A')
					struct.set_facing(current_ghost.get_facing())
					structures_node.add_belt(struct, map_pos.x, map_pos.y)
					structures_node.add_struct(struct, map_pos.x, map_pos.y)
				"Poller":
					structures_node.add_poller(struct, map_pos.x, map_pos.y)
				_:
					structures_node.add_struct(struct, map_pos.x, map_pos.y)
				#_:
				# 	pass

func _input(_event):
	if current_ghost:
		var mouse_pos = get_global_mouse_position()
		var mouse_pos_rounded = Vector2(round(mouse_pos.x), round(mouse_pos.y))
		current_ghost.global_position = background.map_to_world(
			background.world_to_map(mouse_pos_rounded))
	if Input.is_action_just_pressed("rotate_item"):
		if current_ghost and current_ghost.has_method("rotate90"):
			current_ghost.rotate90()
	if Input.is_action_just_pressed("clear_item"):
		clear_current()
	if Input.is_action_just_pressed("connect_mode"):
		Global.click_state = Global.CLICK_MODE.CONNECT
		$BackgroundTiles/Structures/Connections.visible = true
	elif Input.is_action_just_released("connect_mode"):
		Global.click_state = Global.CLICK_MODE.NORMAL
		structures_node.clear_connect_requests()
		$BackgroundTiles/Structures/Connections.visible = false
		
func _instance_item(index):
	clear_current()
	current_placeable = index
	current_ghost = structures[index]["resource"].instance()
	self.add_child(current_ghost)

func clear_current():
	if current_ghost:
		current_placeable = -1
		current_ghost.queue_free()
		current_ghost = null

func _on_Structures_clicked(machine, request):
	emit_signal("machine_clicked", machine, request)

func _on_Structures_sound_requested(sound_name):
	match sound_name:
		"drill":
			$Sounds/Drill.play()
