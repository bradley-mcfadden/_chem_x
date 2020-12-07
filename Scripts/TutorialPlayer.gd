extends TabContainer

onready var streams := []

func _ready():
	for child in get_children():
		for w in child.get_children():
			if w is MarginContainer:
				var z = w.get_child(0)
				streams.append(z)
				z.connect("finished", self, "_on_Video_finished")
	if len(streams) > 0:
		_on_TabContainer_tab_changed(0)

func stop_all_streams():
	for stream in streams:
		stream.stop()
		# endfor
	# endfor

func _on_TabContainer_tab_changed(tab):
	print('changed tab %s' % tab)
	# stop_all_streams()
	print(streams[tab])
	streams[tab].play()

func _on_Video_finished():
	streams[current_tab].play()
