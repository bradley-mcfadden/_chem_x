extends Node

# signal struct_added(struct)

signal clicked(machine, request)
signal sound_requested(sound_name)

var belts:Array
var structures:Array
var pollers
var world_size:Vector2

onready var connect_request_line = null
onready var connect_request_a = null
onready var connect_request_b = null
onready var disconnect_req_a  = null
onready var disconnect_req_b  = null
onready var line_mappings := {}

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
	structures[y][x] = struct
	struct._start()
	struct.connect("clicked", self, "_on_Struct_clicked")
	struct.connect("connect_request", self, "_on_Connect_request")
	struct.connect("cut_request", self, "_on_Cut_request")
	struct.connect("disconnect_request", self, "_on_Disconnect_request")

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

func get_struct_at(vec:Vector2):
	return structures[vec.y][vec.x]

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
		connect_request_b = machine
		var dist := abs(connect_request_a - connect_request_b)
		var line = $Line2D.duplicate()
		var line_id = (str(connect_request_a.get_instance_id()) 
				+ str(connect_request_b.get_instance_id()))
		line_mappings[line_id] = line
		print(line_mappings)
		line.clear_points()
		line.add_point(connect_request_a.global_position)
		line.add_point(connect_request_b.global_position)
		$Connections.add_child(line)
		line.visible = true
		connect_request_a.connect_to_machine(connect_request_b)
		clear_connect_requests()
		emit_signal("sound_requested", "drill")

func _on_Disconnect_request(machine:Object):
	if not disconnect_req_a:
		disconnect_req_a = machine
		return
	if not disconnect_req_b:
		disconnect_req_b = machine
		var line_ids = [str(disconnect_req_a.get_instance_id()), 
				str(disconnect_req_b.get_instance_id())]
		var line_id_a = line_ids[0] + line_ids[1]
		var line_id_b = line_ids[1] + line_ids[0]
		if line_id_a in line_mappings:
			disconnect_req_a.disconnect("output_ready", disconnect_req_b, "check_input")
			disconnect_req_b.disconnect("input_response", disconnect_req_a, "check_output_response")
			disconnect_req_a.disconnect("pass_item", disconnect_req_b, "push_to_inventory")
			$Connections.remove_child(line_mappings[line_id_a])
			line_mappings[line_id_a].queue_free()
			line_mappings.erase(line_id_a)
		elif line_id_b in line_mappings:
			disconnect_req_a.disconnect("output_ready", disconnect_req_b, "check_input")
			disconnect_req_b.disconnect("input_response", disconnect_req_a, "check_output_response")
			disconnect_req_a.disconnect("pass_item", disconnect_req_b, "push_to_inventory")
			$Connections.remove_child(line_mappings[line_id_b])
			line_mappings[line_id_b].queue_free()
			line_mappings.erase(line_id_b)
		clear_connect_requests()

func _on_Cut_request(machine:Object):
	# find connections of machine
	var cxns = machine.get_incoming_connections()
	# remove any incoming connections
	for cx in cxns:
		# machine.disconnect(cx['signal_name'], cx['source'], cx['method_name'])
		cx['source'].disconnect(cx['signal_name'], machine, cx['method_name'])
	# queue free machine
	for i in range(len(structures)):
		for j in range(len(structures[i])):
			if machine == structures[i][j]:
				if belts[i][j]:
					belts[i][j] = null
					# update neighbours
					var sink = pointing_at(Vector2(i, j), machine.facing)
					belts[sink.x][sink.y].reset()
					for b in neighbour_tiles(sink):
						if belts[b.x][b.y] and pointing_at(b, belts[b.x][b.y].facing) == sink:
							belts[sink.x][sink.y].new_source(belts[b.x][b.y].facing)
					belts[i][j] = null
				structures[i][j] == null
				machine.queue_free()
				break

func clear_connect_requests():
	connect_request_a = null 
	connect_request_b = null
	disconnect_req_a  = null
	disconnect_req_b  = null
