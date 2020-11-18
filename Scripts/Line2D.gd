extends Line2D

onready var aaa_active := true

func _ready():
	clear_points()

func _process(_delta):
	if len(points) > 1:
		set_point_position(1, get_global_mouse_position())
		if abs(points[0].x - points[1].x) > 48 or abs(points[0].y - points[1].y) > 48:
			visible = false
			pass
		else:
			visible = true

# func reset():
# 	clear_points()
# 	visible = false
	# clear_points()
