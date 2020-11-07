extends Panel


var is_expanded = false
var panel_size = 0

func _ready():
	pass
	
func calculate_panel_size():
	panel_size = 0
	var spacing = get_parent().spacing
	for child in $VBoxContainer.get_children():
		panel_size += child.rect_size.y + spacing
	if $VBoxContainer.get_child_count() > 0:
		panel_size -= spacing
	# print('PS: ', panel_size)

func expand():
	is_expanded = !is_expanded
	calculate_panel_size()

var last_rect_size = Vector2.ZERO
func _process(_delta):

	#snap to end
	if abs(rect_size.y-rect_min_size.y) < 1:
		rect_size.y = rect_min_size.y

	#resize to target size
	if is_expanded:
		rect_size.y = lerp(rect_size.y, panel_size, 0.1)
	else:
		rect_size.y = lerp(rect_size.y, rect_min_size.y, 0.1)

	#update layout
	if last_rect_size != rect_size:
		get_parent().update()
		last_rect_size = rect_size
