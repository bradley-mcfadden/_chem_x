extends Node

onready var level_index = 0
onready var level = null

func change_level():
	if not level:
		$MarginContainer.hide()
	else:
		remove_child(level)
		level.queue_free()
	if level_index >= len(Global.LEVELS):
		$MarginContainer.show()
	else:
		var temp = load(Global.LEVELS[level_index])
		level = temp.instance()
		level.connect("level_finished", self, "_on_LevelFinished")
		add_child(level)
		level_index += 1

func _on_LevelFinished():
	change_level()

func _on_StartGame_button_up():
	change_level()

func _on_Quit_button_up():
	get_tree().quit()
