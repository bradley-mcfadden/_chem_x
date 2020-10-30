extends Node2D
class_name Entity

var max_time
var dtime
var target
var starting_position
var do_lerp

# Performs leprp on this object
func _process(delta):
	if do_lerp and dtime < max_time:
		dtime += delta
		var p_dtime = dtime / max_time
		global_position = lerp(starting_position, target, p_dtime)
	else:
		do_lerp = false

# Sets destination and time needed to move item from current position to _target
func set_lerp_target(_target, _max_time):
	dtime = 0
	starting_position = global_position
	do_lerp = true
	self.target = _target
	self.max_time = _max_time
