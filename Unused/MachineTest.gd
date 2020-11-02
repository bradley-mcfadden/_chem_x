extends Node2D

var A:Node2D
var B:Node2D
var C:Node2D
var S1:Node2D
var S2:Node2D

func _ready():
	S1 = $Source
	S2 = $Sink
	A = $Machine
	B = $Machine2
	C = $Machine3
	S1.connect_to_machine(A)
	A.connect_to_machine(B)
	B.connect_to_machine(C)
	C.connect_to_machine(S2)
	print(A.get_incoming_connections())
	print(B.get_incoming_connections())
	print(C.get_incoming_connections())
