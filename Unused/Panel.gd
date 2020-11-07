extends Panel

var is_expanded = false
var expanded_size = 0 
var spacing = 0


func set_spacing(spc):
	spacing = spc
	for child in $VBoxContainer.get_children():
		expanded_size += child.rect_size.y + spacing
	expanded_size -= spacing
	# print(expanded_size)
	# print(spacing)

func expand():
	# print(spacing)
	is_expanded = !is_expanded
	# print(is_expanded)
	# print(rect_min_size)
	# print(rect_size)

var last_rect_size = Vector2.ZERO
func _process(delta):

	#snap to end
	if abs(rect_size.y - rect_min_size.y) < 1:
		rect_size.y = rect_min_size.y

	#resize to target size
	if is_expanded:
		# rect_size.y = lerp(rect_size.y, expanded_size, 0.1)
		rect_size.y = lerp(rect_size.y, expanded_size, 0.1)
	else:
		rect_size.y = lerp(rect_size.y, rect_min_size.y, 0.1)

	#update layout
	if last_rect_size != rect_size:
		get_parent().get_parent().update()
		last_rect_size = rect_size


func _on_show_pressed():
	pass # Replace with function body.
