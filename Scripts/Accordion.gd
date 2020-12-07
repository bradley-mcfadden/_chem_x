extends Control

export var spacing = 10
var show_space = false

func _ready():
	$MarginContainer/Panel/VBoxContainer.add_constant_override("separation", spacing)
	$MarginContainer/Panel.set_spacing(spacing)
	

func _draw():
	var last_end_anchor = Vector2.ZERO
	for child in get_children():
		if child == $BGPanel:
			continue
		child.rect_position = last_end_anchor
		last_end_anchor.y = child.rect_position.y + child.rect_size.y
		last_end_anchor.y += spacing
		# print(child, ' ', last_end_anchor)
		
	rect_min_size.y = last_end_anchor.y # to work with ScrollContainer
	print('LEA: ', rect_min_size.y)
	$BGPanel.rect_position.y = $show.rect_position.y
	if show_space:
		$BGPanel.rect_size.y = $show.rect_size.y + spacing # + spacing
	else:
		$BGPanel.rect_size.y = $show.rect_size.y
	print($BGPanel.rect_size.y, ' ', $BGPanel.rect_position.y)

func toggle_bg_size():
	show_space = !show_space
