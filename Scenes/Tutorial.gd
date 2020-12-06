extends MarginContainer

signal closed()

onready var tab_count := 0
onready var tabs := $PanelContainer/VBoxContainer/TabContainer
onready var next_btn := $PanelContainer/VBoxContainer/HBoxContainer2/NextButton
onready var prev_btn := $PanelContainer/VBoxContainer/HBoxContainer2/PreviousButton
onready var prog_label := $PanelContainer/VBoxContainer/HBoxContainer2/Progress

func _ready():
	tab_count = tabs.get_tab_count()
	update_ui()


func _on_PreviousButton_pressed():
	if tabs.current_tab == 0:
		return
	else:
		tabs.current_tab -= 1
	update_ui()

func _on_NextButton_pressed():
	if tabs.current_tab == tab_count - 1:
		return
	else:
		tabs.current_tab += 1
	update_ui()

func update_ui():
	prog_label.text = '%s / %s' % [tabs.current_tab + 1, tab_count]
	if tabs.current_tab == tab_count - 1:
		next_btn.disabled = true
	else:
		next_btn.disabled = false
	if tabs.current_tab == 0:
		prev_btn.disabled = true
	else:
		prev_btn.disabled = false


func _on_CloseButton_pressed():
	hide()
	emit_signal("closed")
