extends KinematicBody2D

signal item_selected(index)

export var movespeed:int = int(192 / 60)

var placeable_item:PackedScene
var in_hand

onready var direction := Vector2()
onready var camera := $Camera2D
# onready var hud := $CanvasLayer/GUI

# func _ready():
# 	camera = $Camera2D
# 	hud = $CanvasLayer/GUI

func _input(_event):
	direction = Vector2()
	var change = false
	if Input.is_action_pressed("move_north"):
		direction.y = -1
		change = true
	if Input.is_action_pressed("move_south"):
		direction.y = 1
		change = true
	if Input.is_action_pressed("move_west"):
		direction.x = -1
		change = true
	if Input.is_action_pressed("move_east"):
		direction.x = 1
		change = true
	if change == true:
		self.rotation = direction.angle()
	if Input.is_action_pressed("zoom_in") and camera.zoom.x <= 1 and camera.zoom.y <= 1:
		camera.zoom += Vector2(1.0/25, 1.0/25)
		print(camera.zoom)
	if Input.is_action_pressed("zoom_out")  and camera.zoom.x >= 0.3 and camera.zoom.y >= 0.3:
		camera.zoom -= Vector2(1.0/25, 1.0/25)
		print(camera.zoom)
	direction = direction.normalized()

func _physics_process(_delta):
	move_and_collide(direction * movespeed)

# func setup_hotbar(items):
# 	# print(items)
# 	hud.add_items(items)

func _hotbar_selected(index):
	emit_signal("item_selected", index)
