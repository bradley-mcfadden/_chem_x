extends Node2D

signal machine_clicked(machine, request)
signal level_finished()

var current_placeable:int
var current_ghost:Node2D
var placeable_tiles = preload("res://Placeable Scenes/PlaceableItems.tscn")
var structures:Array

var hammer_c = load("res://Icons/Hammer.png")
var scissors_c = load("res://Icons/Scissors.png")
var link_add_c = load("res://Icons/LinkAdd.png")
var link_min_c = load("res://Icons/LinkMin.png")

export var world_rect:Vector2 = Vector2(30, 20)
export(Array, Dictionary) var p_goals = []

onready var player := $Player
onready var background := $BackgroundTiles
onready var structures_node := $BackgroundTiles/Structures
onready var sinks := []
onready var global_sum := 0
onready var global_avg := 0.0
onready var goal_counts := {}
onready var elapsed_time := 0
onready var inter_size := 5
onready var inter_counter := 0
onready var inter_container := []

func _ready():
	for i in range(inter_size):
		inter_container.append(0)
	structures = placeable_tiles.instance().get_loaded_children()
	$CanvasLayer/Hotbar.add_items(structures)
	structures_node.setup_world_size(world_rect)
	Global.load_items()
	for child in $BackgroundTiles/Structures/SourceSinkGroup.get_children():
		print(child)
		print(sinks)
		if child.has_method("get_count"):
			sinks.append(child)
			# if not production_item == '':
			# 	child.set_current_item(production_item)
	$CanvasLayer/Production.set_goals(p_goals)
	Input.set_custom_mouse_cursor(hammer_c)

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
					# print('yes, adding a Belt_A')
					struct.set_facing(current_ghost.get_facing())
					structures_node.add_struct(struct, map_pos.x, map_pos.y)
					structures_node.add_belt(struct, map_pos.x, map_pos.y)
				"Poller":
					structures_node.add_poller(struct, map_pos.x, map_pos.y)
				_:
					structures_node.add_struct(struct, map_pos.x, map_pos.y)
				#_:
				# 	pass

func _input(_event):
	if Input.is_action_just_pressed("next_level"):
		emit_signal("level_finished")
	if current_ghost:
		var mouse_pos = get_global_mouse_position()
		var mouse_pos_rounded = Vector2(int(mouse_pos.x), int(mouse_pos.y))
		# the following code rounds the map coordinates up if the remainder 
		# is greater than 15.
		# this makes building more accurate.
		var q = background.world_to_map(mouse_pos_rounded)
		var r = Vector2(int(mouse_pos_rounded.x) % 32, int(mouse_pos_rounded.y) % 32)
		if r.x > 15:
			q.x += 1
		if r.y > 15:
			q.y += 1
		current_ghost.global_position = background.map_to_world(q)
		# if dist(mouse_pos, player.global_position) >= 10 tiles
		if mouse_pos.distance_to(player.global_position) >= 32 * 10:
			if current_ghost.is_placeable:
				current_ghost.set_placeable(false)
			else:
				pass
			current_ghost.set_placeable(false)
	if Input.is_action_just_pressed("rotate_ccw"):
		if current_ghost and current_ghost.has_method("rotateN90"):
			current_ghost.rotateN90()
	elif Input.is_action_just_pressed("rotate_cw"):
		if current_ghost and current_ghost.has_method("rotate90"):
			current_ghost.rotate90()	
	if Input.is_action_just_pressed("normal_mode"):
		set_normal_state()
	elif Input.is_action_just_pressed("connect_mode"):
		clear_current()
		Global.click_state = Global.CLICK_MODE.CONNECT
		Input.set_custom_mouse_cursor(link_add_c)
		$BackgroundTiles/Structures/Connections.visible = true
		# reset structures node
		structures_node.clear_connect_requests()
	elif Input.is_action_just_pressed("disconnect_mode"):
		clear_current()
		structures_node.clear_connect_requests()
		Global.click_state = Global.CLICK_MODE.DISCONNECT
		Input.set_custom_mouse_cursor(link_min_c)
		$BackgroundTiles/Structures/Connections.visible = true
	elif Input.is_action_just_pressed("cut_mode"):
		clear_current()
		structures_node.clear_connect_requests()
		Global.click_state = Global.CLICK_MODE.CUT
		Input.set_custom_mouse_cursor(scissors_c)
		$BackgroundTiles/Structures/Connections.visible = false
		
func _instance_item(index):
	clear_current()
	current_placeable = index
	current_ghost = structures[index]["resource"].instance()
	self.add_child(current_ghost)
	var mouse_pos = get_global_mouse_position()
	var mouse_pos_rounded = Vector2(int(mouse_pos.x), int(mouse_pos.y))
	# the following code rounds the map coordinates up if the remainder 
	# is greater than 15.
	# this makes building more accurate.
	var q = background.world_to_map(mouse_pos_rounded)
	var r = Vector2(int(mouse_pos_rounded.x) % 32, int(mouse_pos_rounded.y) % 32)
	if r.x > 15:
		q.x += 1
	if r.y > 15:
		q.y += 1
	current_ghost.global_position = background.map_to_world(q)

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
	elapsed_time += $ScoringTimer.wait_time
	var win_flag := true
	var prev_counts := goal_counts.duplicate(true)
	for key in goal_counts.keys():
		goal_counts[key] = 0
	for sink in sinks:
		var key = sink.get_current_item_id()
		if not key in goal_counts:
			goal_counts[key] = 0
			prev_counts[key] = 0
		# goal_counts[key] = 0
		goal_counts[key] += sink.get_count()
	for key in goal_counts.keys():
		var prev_count = prev_counts[key]
		var curr_count = goal_counts[key]
		var inter = float(curr_count - prev_count) / $ScoringTimer.wait_time
			# get elapsed time
			# update production to use current count / elapsed time
		# print('Inter ', inter)
		if inter_counter < inter_size:
			inter_container[inter_counter] = inter
			inter_counter += 1
		else:
			inter_counter = 0
		var inter_sum := 0.0
		for i in inter_container:
			inter_sum += i
		# print('Inter sum ', inter_sum, ' Interc ', inter_container, ' Inter size ', inter_size)
		var current_production := float(inter_sum) / inter_size
		$CanvasLayer/Production.update_production(key, current_production) # / (elapsed_time / $ScoringTimer.wait_time))
		for goal in p_goals:
			if key == goal['item_id'] and not (current_production >= goal['rate']):
				win_flag = false
	if win_flag:
		emit_signal("level_finished")

func _on_BuildRequested():
	set_normal_state()

func set_normal_state():
	clear_current()
	structures_node.clear_connect_requests()
	Global.click_state = Global.CLICK_MODE.NORMAL
	Input.set_custom_mouse_cursor(hammer_c)
	$BackgroundTiles/Structures/Connections.visible = false
