extends Node

enum MODE {EDIT, PAUSE, PLAY}
enum CLICK_MODE {CONNECT, NORMAL, DISCONNECT, CUT}

const LEVELS = ["res://Scenes/World0.tscn"]
onready var play_state:int = MODE.PLAY
onready var click_state:int = CLICK_MODE.NORMAL
onready var item_table:Array
onready var recipe_table:Array

func _ready():
	item_table = load_items()
	recipe_table = load_recipes()

# Load item data from res://Data/items.json
func load_items():
	var item_file = File.new()
	if not item_file.file_exists('res://Data/items.json'):
		# print('Returning from file read')
		return
	item_file.open('res://Data/items.json', File.READ)
	var string = item_file.get_as_text()
	return parse_json(string)

# Load recipe data from res://Data/recipes.json
func load_recipes():
	var recipe_file = File.new()
	if not recipe_file.file_exists('res://Data/recipes.json'):
		# print('Returning from file read')
		return
	recipe_file.open('res://Data/recipes.json', File.READ)
	var string = recipe_file.get_as_text()
	return parse_json(string)

func get_item_table():
	return item_table

func get_recipe_table():
	return recipe_table

func get_item(id):
	for item_d in item_table:
		if item_d['id'] == id:
			return item_d
	return null
