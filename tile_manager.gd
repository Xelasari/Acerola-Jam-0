extends Node2D

# Current problem: tile_groups are very hard to work with
# Attempted solution?: tiles adhoc handle themselves?
# Maybe have a global variable counting up and down "tile groups"
# when merging two tiles, decrement tile groups, when splitting increment
# movement is handled via signals, ie "move group 3, to position x, y"

# This node will contain all tiles and handle merging

# Nodes should always be counted from the top left
# so if two "(0, 0)" nodes get connected, it will turn into
# (0, 0) and (0, 1), for example


@export var tileScene : PackedScene

var connect_cooldown : int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if connect_cooldown != 0:
		connect_cooldown -= 1
	pass
	
func create_tile_at(local_coord):
	var new_tile = tileScene.instantiate()
	new_tile.position = local_coord * 32
	new_tile.local_position = Vector2i(0, 0)
	#new_tile.connect("start_drag", _on_start_drag)
	#new_tile.connect("end_drag", _on_end_drag)
	new_tile.connect("connect_two_tiles", _on_connect_two_tiles)
	#tiles_in_group.append(new_tile)
	add_child(new_tile)
	pass

func _on_connect_two_tiles(tile1, tile2, edge_side):
	if connect_cooldown != 0: return
	
	print("Edge side: " + str(edge_side))
	
	# all of this should happen on mouse release, so that can help how to think about things
	
	
	
	# get all tiles connected to tile1
	
	var tile1_group = tile1.tiles_connected_to
	
	# get all tiles connected to tile2
	
	var tile2_group = tile2.tiles_connected_to
	
	# use tile1 and edge_side to create offset for all tiles connected to tile2
	
	# need to find largest x, y in tile1 and add to shift vector (I think)
	# This is actually probably specific for which direction it is being connected to
	# consider left connection
	# this is dealing with x coordinate
	# you need tile2 x coordinate
	# left connection difference between tile1 and tile2 (plus side)
	# (0, 0) - tile2:(1, 0) + constant:(-1, 0) == shift vector 
	
	var max_x : int = -999999
	var max_y : int = -999999
	
	for t in tile1.tiles_connected_to:
		if max_x < t.local_position.x:
			max_x = t.local_position.x
		if max_y < t.local_position.y:
			max_y = t.local_position.y	
	
	print("max vector: " + str(max_x) + ", " + str(max_y))
	
	var shift_vector : Vector2i = Vector2i(0, 0)
	
	print("tile1.local_position: " + str(tile1.local_position))
	print("tile2.local_position: " + str(tile2.local_position))
	
	#shift_vector = Vector2i(max_x, max_y)
	print(shift_vector)
	match edge_side:
		EdgeComponent.EDGE_SIDE.TOP:
			shift_vector = tile1.local_position - tile2.local_position
			shift_vector += Vector2i(0, -1)
		EdgeComponent.EDGE_SIDE.BOTTOM:
			shift_vector += Vector2i(0, 1)
		EdgeComponent.EDGE_SIDE.RIGHT:
			shift_vector = tile1.local_position + tile2.local_position
			shift_vector += Vector2i(1, 0)
		EdgeComponent.EDGE_SIDE.LEFT:
			shift_vector = tile1.local_position - tile2.local_position
			shift_vector += Vector2i(-1, 0)
			
	print("shift vector: " + str(shift_vector))
	
	#tile1.disable_edge_collision(edge_side, true)
	#tile2.disable_edge_collision((edge_side + 2) % 4, true)
	
	#tile1.turn_off_edges()
	#tile2.turn_off_edges()
	
	# offset tile2 group
	
	for t in tile2_group:
		t.local_position += shift_vector
	
	# make sure all tiles know of each other
	var new_tiles_connected_to : Array
	
	for t in tile1.tiles_connected_to:
		new_tiles_connected_to.append(t)
	
	for t in tile2.tiles_connected_to:
		new_tiles_connected_to.append(t)
		
	for t in new_tiles_connected_to:
		t.tiles_connected_to = new_tiles_connected_to
	
	# using tile1, set new positions for clean tiling
	
	var reference_pos = tile1.position
	for t in tile1.tiles_connected_to:
		#if t == tile1: continue
		t.position = reference_pos + Vector2((t.local_position * 32))
		#t.position = Vector2((t.local_position * 32))
	
	# iterate through all tiles in new tile set to re-calculate top left corner
	
	var smallest_x : int = 9999999999
	var smallest_y : int = 9999999999
	for t in tile1.tiles_connected_to:
		if smallest_x > t.local_position.x:
			smallest_x = t.local_position.x
		if smallest_y > t.local_position.y:
			smallest_y = t.local_position.y	
	
	print("Smallest: (" + str(smallest_x) + ", " + str(smallest_y) +")")
	
	# use new top left corner to properly set all tiles
	for t in tile1.tiles_connected_to:
		t.local_position += Vector2i(abs(smallest_x), abs(smallest_y))
	
	
	
	# This point should be the 0, 0 position, from which 
	var reference_point : Vector2
	
	
	# Re-calculate all edges, see if they need to be turned off
	var tiles_at : Dictionary
	for t in tile1.tiles_connected_to:
		tiles_at[t.local_position] = true
		
	for t in tile1.tiles_connected_to:
		var check 
		check = t.local_position + Vector2i(0, -1)
		if tiles_at.has(check):
			t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.TOP, true)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.TOP, true)
		check = t.local_position + Vector2i(1, 0)
		if tiles_at.has(check):
			t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.RIGHT, true)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.RIGHT, true)
		check = t.local_position + Vector2i(0, 1)
		if tiles_at.has(check):
			t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.BOTTOM, true)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.BOTTOM, true)
		check = t.local_position + Vector2i(-1, 0)
		if tiles_at.has(check):
			t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.LEFT, true)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.LEFT, true)
	
	
	print("------------------------------------------")
	
	
	connect_cooldown = 3
	
