extends Line2D

onready var aaa_active := true

func _ready():
	clear_points()

func _process(_delta):
	if len(points) > 1:
		set_point_position(1, get_global_mouse_position())
		var x0 := points[0].x
		var y0 := points[0].y
		var x1 := points[1].x
		var y1 := points[1].y
#		if abs(points[0].x - points[1].x) > 48 or abs(points[0].y - points[1].y) > 48:
#			visible = false
#			pass
#		else:
#			visible = true
		if ((abs(x0 - x1) <= 48 and abs(y0 - y1) <= 16) 
		or (abs(y0 - y1) <= 48 and abs(x0 - x1) <= 16)):
			visible = true
		else:
			visible = false
#		var delta_x := points[1].x - points[0].x
#		var delta_y := points[0].y - points[1].y
#		var ang := atan2(delta_y, delta_x)
#		print(ang)

# func reset():
# 	clear_points()
# 	visible = false
	# clear_points()
