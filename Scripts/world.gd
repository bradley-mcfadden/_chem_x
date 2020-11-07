extends Node2D

signal machine_clicked(machine, request)
signal level_finished()

var current_placeable:int
var current_ghost:Node2D
var placeable_tiles = preload("res://Placeable Scenes/PlaceableItems.tscn")
var structures:Array

export var world_rect:Vector2 = Vector2(30, 20)
export var production_goal := 100.0 # in units per min
export var production_item := ''

onready var player := $Player
onready var background := $BackgroundTiles
onready var structures_node := $BackgroundTiles/Structures
onready var sinks := []
onready var global_sum := 0
onready var global_avg := 0.0

func _ready():
	structures = placeable_tiles.instance().get_loaded_children()
	player.setup_hotbar(structures)
	structures_node.setup_world_size(world_rect)
	Global.load_items()
	for child in $BackgroundTiles/Structures/SourceSinkGroup.get_children():
		if child.has_method("get_count"):
			sinks.append(child)
			if not production_item == '':
				child.set_current_item(production_item)

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

func _on_ScoringTimer_timeout():
	var temp = 0
	for sink in sinks:
		temp += sink.get_count()
	global_sum = temp
	global_avg = global_sum / len(sinks)
	if global_avg >= production_goal:
		emit_signal("level_finished")
