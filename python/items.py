import random
import json
import string

def h():
	print('random_string(length:int) -> string')
	print('add_item(item_table:list, name:string) -> list')
	print('add_recipe(recipe_table:list, item_table:list, name:string, quantity:int, speed:float, components:list) -> list')
	print('load_file(fname:string) -> dict')
	print('dump_file(data:object, fname:string) -> None')
	print('print_json(data:object) -> None')

def random_string(length):
	chars = string.ascii_lowercase + string.ascii_uppercase + string.digits
	return ''.join([random.choice(chars) for i in range(length)])

def add_item(item_table, name):
	d = {}
	for g in item_table:
		if g['name'] == name:
			return item_table
	# endfor 
	d['id'] = random_string(16)
	d['name'] = name
	item_table.append(d)
	return item_table

def add_recipe(recipe_table, item_table, name, quantity, speed, components):
	r = {}
	item_id = None
	for g in item_table:
		if g['name'] == name:
			item_id = g['id']
	# endrow
	if not item_id:
		return recipe_table
	r['id'] = item_id
	r['quantity'] = quantity
	r['speed'] = speed
	r['ingredients'] = []
	for c in components:
		it_id = None
		for g in item_table:
			if g['name'] == c['name']:
				it_id = g['id']
		# endfor
		if not it_id:
			return item_table
		ing = {}
		ing['id'] = it_id
		ing['quantity'] = c['quantity']
		r['ingredients'].append(ing)
	# endfor
	recipe_table.append(r)
	return recipe_table
		
def load_file(fname):
	with open(fname, 'r') as f:
		return json.load(f)
	
def dump_file(data, fname):
	with open(fname, 'w') as f:
		json.dump(data, f, indent=4)

def print_json(obj):
	print(json.dumps(parsed, indent=4, sort_keys=True))
