extends Node
class_name Queue
var array
var size
var start = 0
var end = -1
var mutex = Mutex.new()

signal item_removed

func _init(max_size):
	array = []
	for _i in range(max_size):
		array.append(null)
	size = 0

func _get_next_index(index):
	var next_index = index + 1
	if next_index >= len(array):
		return 0
	return next_index

func is_empty():
	return size > 0

func is_full():
	return size != array.size()

func push(object):
	if size == len(array):
		yield(self, "item_removed")
	mutex.lock()
	end = _get_next_index(end)
	size += 1
	array[end] = object
	mutex.unlock()

func pop():
	if size < 1:
		return null
	mutex.lock()
	var item = array[start]
	array[start] = null
	start = _get_next_index(start)
	size -= 1
	mutex.unlock()
	emit_signal("item_removed")
	return item

func peek():
	if size < 1:
		return null
	mutex.lock()
	var item = array[start]
	mutex.unlock()
	return item

func _to_string():
	return str(array) 
