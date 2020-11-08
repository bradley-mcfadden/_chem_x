extends "res://Scripts/Machine.gd"

class_name Belt_A

enum Animat {LINEAR, LEFT_CORNER, RIGHT_CORNER}
onready var facing:int = Constants.Direction.NORTH
onready var num_perp_sinks:int = 0
 
func _ready():
	$Button.disabled = true

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
	sprite.play('linear')

func set_left_corner():
	sprite.play('left_corner')

func set_right_corner():
	sprite.play('right_corner')

func reset():
	num_perp_sinks = 0
	set_linear()

# Update animation to match inputs
func new_source(direction:int):
	# print(direction, ' ', facing)
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
	# print(Global.click_state)
	match Global.click_state:
		Global.CLICK_MODE.NORMAL:
			pass
		Global.CLICK_MODE.CONNECT:
			emit_signal("connect_request", self)

# Perform a lerp on item after moving receiving it from other machine
func push_to_inventory(item):
	# print(self, ' accepting ', item)
	var _item_scene = load(item['path']).instance()
	get_parent().add_child(_item_scene)
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
	_item_scene.set_lerp_target(self.global_position, 0.5 * process_time)
	yield(get_tree().create_timer(0.5 * process_time),"timeout")
	_item_scene.global_position = self.global_position
	_item_scene.set_lerp_target(end_position, 0.5 * process_time)
	yield(get_tree().create_timer(0.5 * process_time), "timeout")
	inventory.push(item)
	_item_scene.queue_free()
