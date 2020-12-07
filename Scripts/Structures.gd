extends Node

# signal struct_added(struct)

signal clicked(machine, request)
signal sound_requested(sound_name)

var belts:Array
var structures:Array
var pollers
var world_size:Vector2

onready var connect_request_line := $Line2D
onready var connect_request_a = null
onready var connect_request_b = null
onready var disconnect_req_a  = null
onready var disconnect_req_b  = null
onready var line_mappings := {}

func _ready():
	for child in $SourceSinkGroup.get_children():
		child.place()
		child.connect("connect_request", self, "_on_Connect_request")
		child.connect("disconnect_request", self, "_on_Disconnect_request")

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
	# This piece of code is for updating the surrounding belts if a current
	# belt is replaced.
	if belts[y][x]:
		# Sink: The tile the belt points at
		var sink = pointing_at(Vector2(y, x), belts[y][x].facing)
		# b is a neighbour of the belt
		for b in neighbour_tiles(Vector2(y, x)):
			# If the belt was pointing at b
			if belts[b.x][b.y] and b == sink:
				# Update b visually
				for a in neighbour_tiles(b):
					if belts[a.x][a.y]:
						belts[a.x][a.y].reset()
						belts[a.x][a.y].new_source(belts[b.x][b.y].get_facing())
				# Disconnect the previous belt and b
				_on_Disconnect_request(belt[y][x])
				_on_Disconnect_request(b)
				_on_Cut_request(b)
		belts[y][x].queue_free()
	belts[y][x] = belt
	# For each neighbour of the belt
	for a in neighbour_tiles(Vector2(y, x)):
		var n = belts[a.x][a.y]
		# If there is a belt n on this tile, and it's pointing at towards us 
		if n and Vector2(y, x) == pointing_at(a, n.get_facing()):
			# Update n visually
			belt.new_source(n.get_facing())
			# Connect the output from n to this belt
			_on_Connect_request(n)
			_on_Connect_request(belt)
	# Holding shift while placing a belt broke things earlier, not sure why
	# but this fixes whatever problem was happening
	if Input.is_action_pressed("shift"):
		return
	# Get the tile the belt is pointing at
	var sink = pointing_at(Vector2(y, x), belt.facing)
	# If there is a belt on the tile this belt faces
	if belts[sink.x][sink.y]:
		# Update the tile visually
		belts[sink.x][sink.y].new_source(belt.facing)
		# Connect the output of this belt to that belt
		_on_Connect_request(belts[y][x])
		_on_Connect_request(belts[sink.x][sink.y])
	# One final check that this belt will be linear if it has no sources
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
		connect_request_line.visible = true
		connect_request_line.add_point(connect_request_a.global_position)
		connect_request_line.add_point(connect_request_a.global_position)
		return
	if not connect_request_b:
		if not connect_request_line.visible:
			return
		connect_request_b = machine
		var line:Line2D = Line2D.new()
		var line_id = (str(connect_request_a.get_instance_id()) 
				+ str(connect_request_b.get_instance_id()))
		line.add_point(connect_request_a.global_position)
		line.add_point(connect_request_b.global_position)
		line.default_color = Color(1.0, 0.67, 0, 1)
		line.width = 10
		line.visible = true
		line.begin_cap_mode = Line2D.LINE_CAP_ROUND
		line.end_cap_mode = Line2D.LINE_CAP_ROUND
		$Connections.add_child(line)
		line_mappings[line_id] = line
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
			disconnect_req_b.disconnect("output_ready", disconnect_req_a, "check_input")
			disconnect_req_a.disconnect("input_response", disconnect_req_b, "check_output_response")
			disconnect_req_b.disconnect("pass_item", disconnect_req_a, "push_to_inventory")
			$Connections.remove_child(line_mappings[line_id_b])
			line_mappings[line_id_b].queue_free()
			line_mappings.erase(line_id_b)
		emit_signal("sound_requested", "power_down")
		clear_connect_requests()

func _on_Cut_request(machine:Object):
	# find connections of machine
	var cxns = machine.get_incoming_connections()
	# remove any incoming connections
	for cx in cxns:
		# machine.disconnect(cx['signal_name'], cx['source'], cx['method_name'])
		cx['source'].disconnect(cx['signal_name'], machine, cx['method_name'])
	# destroy any visual connections this machine previously had
	for l in line_mappings.keys():
		if (l.substr(0, 4) == str(machine.get_instance_id()) 
		or l.substr(4, 4) == str(machine.get_instance_id())):
			$Connections.remove_child(line_mappings[l])
			line_mappings[l].queue_free()
			line_mappings.erase(l)
	# queue free machine
	for i in range(len(structures)):
		for j in range(len(structures[i])):
			if machine == structures[i][j]:
				if belts[i][j]:
					belts[i][j] = null
					# update neighbours
					var sink = pointing_at(Vector2(i, j), machine.facing)
					if belts[sink.x][sink.y]:
						machine.destroy_contents()
						belts[sink.x][sink.y].reset()
						for b in neighbour_tiles(sink):
							if belts[b.x][b.y] and pointing_at(b, belts[b.x][b.y].facing) == sink:
								belts[sink.x][sink.y].new_source(belts[b.x][b.y].facing)
					belts[i][j] = null
				structures[i][j] = null
				remove_child(machine)
				machine.queue_free()
				emit_signal("sound_requested", "cut")
				break

func clear_connect_requests():
	connect_request_a = null 
	connect_request_b = null
	disconnect_req_a  = null
	disconnect_req_b  = null
	connect_request_line.clear_points()
	# connect_request_line.visible = false
