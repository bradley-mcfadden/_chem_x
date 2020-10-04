extends "res://Scripts/PlaceableItem.gd"
class_name Belt

enum Animat {LINEAR, LEFT_CORNER, RIGHT_CORNER}
var facing:int
var num_perp_sinks:int
var animation_stack:Array
 
func _ready():
	facing = Constants.Direction.NORTH
	num_perp_sinks = 0
	animation_stack = []
	animation_stack.push_back(Animat.LINEAR)

func rotate90():
	self.rotate(PI/2)
	facing = (facing + 1) % 4
	print('Now facing ', facing)

func get_facing():
	return facing

func set_facing(facing):
	self.facing = facing

func set_linear():
	sprite.play('linear')

func set_left_corner():
	sprite.play('left-corner')

func set_right_corner():
	sprite.play('right-corner')

func reset():
	num_perp_sinks = 0
	set_linear()

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
	print('Num perp sinks:', num_perp_sinks)

func add_multiple(list_facing:Array):
	num_perp_sinks = 0
	set_linear()
	for l in list_facing:
		new_source(l)
