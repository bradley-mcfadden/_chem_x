extends MarginContainer

export var columns:int = 9

signal item_selected(index)

var item_count:int = 0
var current_row:HBoxContainer
var buttons:Array
var AwareButton

func _ready():
	buttons = []
	AwareButton = $AwareButton
	
func add_items(items):
	# for each item in items
	for item in items:
		# if item_count mod 9 = 0
		if item_count % columns == 0:
			# current_row = new HBoxContainer
			current_row = HBoxContainer.new()
			current_row.add_constant_override("hseparation", 10)
			current_row.alignment = BoxContainer.ALIGN_CENTER
			$VBoxContainer.add_child(current_row)
		# add ImageTexture to current_row
		var image_texture = item['texture']
		var button = AwareButton.duplicate()
		button.texture_normal = image_texture
		button.visible = true
		button.connect("button_up2", self, "_on_hotbar_clicked")
		buttons.append(button)
		current_row.add_child(button)
		item_count += 1

func _on_hotbar_clicked(b): 
	for i in range(len(buttons)):
		if buttons[i] == b:
			emit_signal("item_selected", i)
