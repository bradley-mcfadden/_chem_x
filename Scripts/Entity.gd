extends KinematicBody2D
class_name Entity

var max_time
var dtime
var target
var starting_position
var do_lerp
onready var mc_target = null
onready var end_target = null

func _ready():
	$Label.text = str(self)

# Performs leprp on this object
func _physics_process(delta):
	# if do_lerp and dtime < max_time:
	# 	dtime += delta
	# 	var p_dtime = dtime / max_time
	# 	global_position = lerp(starting_position, target, p_dtime)
	 #else:
	# 	do_lerp = false
	if mc_target:
		move_and_collide(mc_target * delta)
	elif end_target:
		move_and_collide(end_target * delta)
	# move_and_collide(Vector2(1,0))

# Sets destination and time needed to move item from current position to _target
func set_lerp_target(_target, _max_time):
	dtime = 0
	starting_position = global_position
	do_lerp = true
	self.target = _target
	self.max_time = _max_time

func set_end_target(vec):
	end_target = vec

func set_mc_target(vec):
	mc_target = vec

func goto_mc():
	pass

func goto_end():
	pass

func stop(_body):
	if not _body == $GoalArea:
		return
	# print(self, ' ', self.global_position, ' ', _body.global_position)
	if mc_target:
		mc_target = null
	elif end_target:
		end_target = null

func enable_goal_collision():
	# yield(get_tree().create_timer(1),"timeout")
	$GoalArea/CollisionPolygon2D.disabled = false
