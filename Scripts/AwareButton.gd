extends TextureButton

signal button_up2(button)

func _ready():
	self.connect("button_up", self, "on_button_up")

func on_button_up():
	print('pressed')
	emit_signal("button_up2", self)
