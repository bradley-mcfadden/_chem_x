extends MarginContainer

signal item_selected(index)
signal build_requested()

export var columns:int = 9

var current_row:HBoxContainer

onready var item_count := 0
onready var buttons := []
onready var AwareButton = $AwareButton

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
			$Panel/VBoxContainer.add_child(current_row)
		# add ImageTexture to current_row
		var image_texture = item['texture']
		var button = AwareButton.duplicate()
		var iea := InputEventAction.new()
		iea.action = "hotbar_" + str(item_count % columns)
		button.shortcut = ShortCut.new()
		button.shortcut.shortcut = iea
		button.texture_normal = image_texture
		button.visible = true
		button.connect("button_up2", self, "_on_hotbar_clicked")
		buttons.append(button)
		current_row.add_child(button)
		item_count += 1

func _on_hotbar_clicked(b):
	emit_signal("build_requested")
	for i in range(len(buttons)):
		if buttons[i] == b:
			emit_signal("item_selected", i)
		
