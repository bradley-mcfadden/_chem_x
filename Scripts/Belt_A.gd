extends "res://Scripts/Machine.gd"

class_name Belt_A

enum Animat {LINEAR, LEFT_CORNER, RIGHT_CORNER}
onready var facing:int = Constants.Direction.NORTH
onready var num_perp_sinks:int = 0
onready var e_inventory = Queue.new(capacity)
onready var hitbox_lock = false

# func _ready():
# 	$Button.disabled = true

# func _start():
# 	pass

# func start(_body):
#	$Timer.start()

func make_structure():
	.make_structure()
	$MID/CollisionPolygon2D.disabled = true
	$MID_L/CollisionPolygon2D.disabled = true
	$MID_R/CollisionPolygon2D.disabled = true
	$END/CollisionPolygon2D.disabled = false
#	$END_L/CollisionPolygon2D.disabled = true
#	$END_R/CollisionPolygon2D.disabled = true

func check_output():
	if (len($END.get_overlapping_areas()) == 0):
#		and len($END_L.get_overlapping_areas()) == 0 
#		and len($END_R.get_overlapping_areas()) == 0):
		# print('yes')
		return
	if not Global.play_state == Global.MODE.PLAY:
		return false
	if inventory.is_empty():
		var item = inventory.peek()
		emit_signal("output_ready", item)
		# $Timer.stop()

# Adjust variables to match roation direction
func rotate90():
	self.rotate(PI/2)
	facing = (facing + 1) % 4
	output_dir = (output_dir + 1) % 4
	# print(round(rotation_degrees))

func rotateN90():
	self.rotate(-PI/2)
	facing = (facing - 1) % 4
	output_dir = (output_dir - 1) % 4

func get_facing():
	return facing

func set_facing(fc):
	self.facing = fc

func set_linear():
	hitbox_lock = true
	sprite.play('linear')
	$MID/CollisionPolygon2D.disabled = false
	$MID_L/CollisionPolygon2D.disabled = true
	$MID_R/CollisionPolygon2D.disabled = true
	$MID/CollisionPolygon2D.visible = true
	$MID_L/CollisionPolygon2D.visible = false
	$MID_R/CollisionPolygon2D.visible = false
	$END/CollisionPolygon2D.disabled = false
#	$END_L/CollisionPolygon2D.disabled = true
#	$END_R/CollisionPolygon2D.disabled = true
	$END/CollisionPolygon2D.visible = true
#	$END_L/CollisionPolygon2D.visible = false
#	$END_R/CollisionPolygon2D.visible = false
	hitbox_lock = false

func set_left_corner():
	hitbox_lock = true
	sprite.play('left_corner')
	$MID/CollisionPolygon2D.disabled = true
	$MID_L/CollisionPolygon2D.disabled = false
	$MID_R/CollisionPolygon2D.disabled = true
	$MID/CollisionPolygon2D.visible = false
	$MID_L/CollisionPolygon2D.visible = true
	$MID_R/CollisionPolygon2D.visible = false
	$END/CollisionPolygon2D.disabled = false
#	$END_L/CollisionPolygon2D.disabled = false
#	$END_R/CollisionPolygon2D.disabled = true
	$END/CollisionPolygon2D.visible = true
#	$END_L/CollisionPolygon2D.visible = true
#	$END_R/CollisionPolygon2D.visible = false
	hitbox_lock = false

func set_right_corner():
	print('set right corner')
	hitbox_lock = true
	sprite.play('right_corner')
	$MID/CollisionPolygon2D.disabled = true
	$MID_L/CollisionPolygon2D.disabled = true
	$MID_R/CollisionPolygon2D.disabled = false
	$MID/CollisionPolygon2D.visible = false
	$MID_L/CollisionPolygon2D.visible = false
	$MID_R/CollisionPolygon2D.visible = true
	$END/CollisionPolygon2D.disabled = false
#	$END_L/CollisionPolygon2D.disabled = true
#	$END_R/CollisionPolygon2D.disabled = false
	$END/CollisionPolygon2D.visible = true
#	$END_L/CollisionPolygon2D.visible = false
#	$END_R/CollisionPolygon2D.visible = true
	hitbox_lock = false

func reset():
	num_perp_sinks = 0
	set_linear()

# Update animation to match inputs
func new_source(direction:int):
	num_perp_sinks += 1
	match direction:
		Constants.Direction.NORTH:
			match facing:
				Constants.Direction.EAST:
					set_right_corner()
				Constants.Direction.WEST:
					set_left_corner()
				_:
					num_perp_sinks -= 1
		Constants.Direction.SOUTH:
			match facing:
				Constants.Direction.WEST:
					set_right_corner()
				Constants.Direction.EAST:
					set_left_corner()
				_:
					num_perp_sinks -= 1
		Constants.Direction.WEST:
			match facing:
				Constants.Direction.NORTH:
					set_right_corner()
				Constants.Direction.SOUTH:
					set_left_corner()
				_:
					num_perp_sinks -= 1
		Constants.Direction.EAST:
			match facing:
				Constants.Direction.NORTH:
					set_left_corner()
				Constants.Direction.SOUTH:
					set_right_corner()
				_:
					num_perp_sinks -= 1
		_:
			num_perp_sinks -= 1
	if num_perp_sinks == 2 or direction == facing:
		set_linear()
	# print('Num perp sinks:', num_perp_sinks)

func add_multiple(list_facing:Array):
	num_perp_sinks = 0
	set_linear()
	for l in list_facing:
		new_source(l)

func _on_Button_pressed():
	if Global.click_state == Global.CLICK_MODE.NORMAL:
		return
	._on_Button_pressed()

func check_output_response(accept:bool):
	if not inventory.is_empty():
		return
	.check_output_response(accept)
	if accept:
		e_inventory.pop().queue_free()
	

func check_input(item):
	if hitbox_lock:
		emit_signal("input_response", false)
	.check_input(item)

# Perform a lerp on item after moving receiving it from other machine
func push_to_inventory(item):
	if not inventory.is_full():
		return
	# print(self, ' accepting ', item)
	var _item_scene = load(item['path']).instance()
	get_parent().add_child(_item_scene)
	# _item_scene.velocity = Vector2(10, 0)
	# _item_scene.move_and_collide(Vector2(20,0))
	# var rotation_offset := Vector2()
	var start_position := Vector2()
	match sprite.animation:
		"linear":
			start_position = $BOTTOM_SIDE.global_position
		"left_corner":
			start_position = $LEFT_SIDE.global_position
		"right_corner":
			start_position = $RIGHT_SIDE.global_position
	var end_position = $TOP_SIDE.global_position
	_item_scene.global_position = start_position
	_item_scene.set_mc_target(self.global_position - start_position)
	_item_scene.set_end_target(end_position - self.global_position)
	$MID.connect("area_entered", _item_scene, "stop")
	$MID_L.connect("area_entered", _item_scene, "stop")
	$MID_R.connect("area_entered", _item_scene, "stop")
	$END.connect("area_entered", _item_scene, "stop")
#	$END_L.connect("area_entered", _item_scene, "stop")
#	$END_R.connect("area_entered", _item_scene, "stop")
	_item_scene.enable_goal_collision()
	inventory.push(item)
	e_inventory.push(_item_scene)

func left_handler(_a):
	print('left hit')
