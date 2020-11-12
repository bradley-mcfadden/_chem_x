extends Node

# signal struct_added(struct)

signal clicked(machine, request)
signal sound_requested(sound_name)

var belts:Array
var structures:Array
var pollers
var world_size:Vector2
onready var connect_request_a = null
onready var connect_request_b = null

func _ready():
	for child in $SourceSinkGroup.get_children():
		child.connect("connect_request", self, "_on_Connect_request")

func setup_world_size(rect:Vector2):
	world_size = rect
	belts = []
	belts.resize(int(rect.y))
	for i in rect.y:
		belts[i] = []
		for j in rect.x:
			belts[i].append(null)
	structures = belts.duplicate(true)

func add_struct(struct, x, y):
	if structures[y][x]:
		struct.queue_free()
		return
	# print('New structure at:', y, ' ', x)
	structures[y][x] = struct
	struct._start()
	struct.connect("clicked", self, "_on_Struct_clicked")
	struct.connect("connect_request", self, "_on_Connect_request")
	

func add_poller(_poller, _x, _y):
	print('New poller at:', _y, ' ', _x)

func add_belt(belt, x, y):
	for s in neighbour_tiles(Vector2(y, x)):
		var strx = structures[s.x][s.y]
		if strx and pointing_at(s, strx.output_dir):
			pass
	var opt = pointing_at(Vector2(y, x), belt.output_dir)
	if opt and structures[opt.x][opt.y]:
		pass
	#
	#
	# print('New node at:', y, ' ', x)
	if x < 0 or y < 0 or x >= world_size.x or y >= world_size.y:
		belt.queue_free()
		return
	if belts[y][x]:
		# print('replacing belt')
		var sink = pointing_at(Vector2(y, x), belts[y][x].facing)
		# print('Sink:', sink)
		for b in neighbour_tiles(Vector2(y, x)):
			# print(b)
			if belts[b.x][b.y] and b == sink:
				# print('b is sink')
				for a in neighbour_tiles(b):
					if belts[a.x][a.y]:
						belts[a.x][a.y].reset()
						belts[a.x][a.y].new_source(belts[b.x][b.y].get_facing())
		belts[y][x].queue_free()
	belts[y][x] = belt
	for a in neighbour_tiles(Vector2(y, x)):
		var n = belts[a.x][a.y]
		# print (a, ' ', belts[a.x][a.y])
		if n and Vector2(y, x) == pointing_at(a, n.get_facing()):
			# print('there is a source')
			belt.new_source(n.get_facing())
	var sink = pointing_at(Vector2(y, x), belt.facing)
	# print('facing ', sink)
	if belts[sink.x][sink.y]:
		# print('there is a sink')
		belts[sink.x][sink.y].new_source(belt.facing)
	if belt.num_perp_sinks == 0:
		belt.set_linear()

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
		_:
			return null

func _on_Timer_timeout():
	pass # Replace with function body.

func _on_Struct_clicked(struct, request):
	emit_signal("clicked", struct, request)

func _on_Connect_request(machine):
	if not connect_request_a:
		connect_request_a = machine
		return
	if not connect_request_b:
		var line = $Line2D.duplicate()
		line.clear_points()
		# line.global_position = connect_request_a.global_position
		line.add_point(connect_request_a.global_position)
		connect_request_b = machine
		line.add_point(connect_request_b.global_position)
		print(line.get_point_count())
		$Connections.add_child(line)
		line.visible = true
		connect_request_a.connect_to_machine(connect_request_b)
		clear_connect_requests()
		emit_signal("sound_requested", "drill")

func clear_connect_requests():
	connect_request_a = null 
	connect_request_b = null
