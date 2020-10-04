extends Node2D

var red_material = preload("res://Shaders/Red.tres")
var green_material = preload("res://Shaders/Green.tres")
var collision_count:int = 0
var is_placeable:bool = true

var ghost_collider:CollisionShape2D
var struct_collider:CollisionShape2D
var sprite:AnimatedSprite

func _ready():
	ghost_collider = $Area2D/CollisionShape2D
	struct_collider = $StaticBody2D/CollisionShape2D2
	sprite = $AnimatedSprite
	sprite.material = green_material
	z_as_relative = false
	z_index = 5


#func check_space_clear():
#	var array:Array = $Area2D.get_overlapping_bodies()
#	return array.size() == 0

func make_structure():
	sprite.material = null
	struct_collider.disabled = false
	ghost_collider.disabled = true
	z_as_relative = true
	z_index = 0

func _on_ghost_entered(_body):
	collision_count += 1
	if collision_count == 1:
		sprite.material = red_material
		is_placeable = false

func _on_ghost_exited(_body):
	collision_count -= 1
	if collision_count == 0:
		sprite.material = green_material
		is_placeable = true
