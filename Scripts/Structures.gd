extends Node

var belts:Array
var structures:Array
var pollers
var world_size:Vector2

func _ready():
	pass

func setup_world_size(rect:Vector2):
	world_size = rect
	belts = []
	belts.resize(rect.y)
	for i in rect.y:
		belts[i] = []
		for j in rect.x:
			belts[i].append(null)
	structures = belts.duplicate(true)

func add_struct(struct, x, y):
	print('New structure at:', y, ' ', x)

func add_poller(poller, x, y):
	print('New poller at:', y, ' ', x)
	poller.n

func add_belt(belt, x, y):
	print('New node at:', y, ' ', x)
	if x < 0 or y < 0 or x >= world_size.x or y >= world_size.y:
		belt.queue_free()
		return
	if belts[y][x]:
		print('replacing belt')
		var sink = pointing_at(Vector2(y, x), belts[y][x].facing)
		print('Sink:', sink)
		for b in neighbour_tiles(Vector2(y, x)):
			print(b)
			if belts[b.x][b.y] and b == sink:
				print('b is sink')
				for a in neighbour_tiles(b):
					if belts[a.x][a.y]:
						belts[a.x][a.y].reset()
						belts[a.x][a.y].new_source(belts[b.x][b.y].get_facing())
		belts[y][x].queue_free()
	belts[y][x] = belt
	for a in neighbour_tiles(Vector2(y, x)):
		var n = belts[a.x][a.y]
		if n and Vector2(y, x) == pointing_at(Vector2(a.x, a.y), n.get_facing()):
			belt.new_source(n.get_facing())
			
	var sink = pointing_at(Vector2(y, x), belt.facing)
	if belts[sink.x][sink.y]:
		# print('there is a sink')
		belts[sink.x][sink.y].new_source(belt.facing)

func neighbour_tiles(vec:Vector2) -> Array:
	var y = vec.x
	var x = vec.y
	return [Vector2(y+1, x), Vector2(y-1, x), Vector2(y, x+1), Vector2(y, x-1)]

func pointing_at(vec:Vector2, direction:int):
	match direction:
		Constants.Direction.NORTH:
			return Vector2(vec.x - 1, vec.y)
		Constants.Direction.EAST:
			return Vector2(vec.x, vec.y + 1)
		Constants.Direction.SOUTH:
			return Vector2(vec.x + 1, vec.y)
		Constants.Direction.WEST:
			return Vector2(vec.x, vec.y - 1)

func _on_Timer_timeout():
	pass # Replace with function body.
