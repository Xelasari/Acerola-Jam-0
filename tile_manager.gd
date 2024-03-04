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


# Next step, clean up stuff

# But then: work on slicing mechanic
# slicing mechanic can likely work off of edges
# for a slice to work, it must start at the highest point and go to the lowest point
# this should probably work nicely

# maybe to make this even more simple, maybe just have a horizontal/vertical line
# following the mouse and use that?

# okay yeah, slicing mechanic
# maybe use a line raycast or something?
# but, when checking for split, take for example vertical cut
# when hit, check every edge connector that was hit, which should have directions
# gather all nodes in group into two, set them, and then reactivate edges
# NOTE: probably need to get connections working on mouse release to prevent bugs
# parameters
# cut: horizontal or verticle
# x or y value1: from 
# x or y value2: to
# ^^^ for example, horizontal, 3, 4:
#	this should make a horizontal slice, between the y values of the tile
# Also, maybe make a check to only cut based on tile group? (to prevent weird shenangins)

# BUG: Need to really polish up drag and connect mechanic (connect on release mouse should really help)


@export var tileScene : PackedScene

var connect_cooldown : int = 0

var check_next : Array[Vector2i]
var already_checked : Array[Vector2i]
var coords_to_check : Array[Vector2i]
var current_building_group : Array


var test_tile_ref = null

# Called when the node enters the scene tree for the first time.
func _ready():
	position += Vector2(16, 16)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if connect_cooldown != 0:
		connect_cooldown -= 1
	pass
	
	
func create_tile_at(local_coord) -> Node:
	var new_tile = tileScene.instantiate()
	new_tile.position = local_coord * 32
	
	print("Creating tile at: " + str(new_tile.position))
	new_tile.local_position = local_coord
	#new_tile.connect("start_drag", _on_start_drag)
	#new_tile.connect("end_drag", _on_end_drag)
	new_tile.connect("connect_two_tiles", _on_connect_two_tiles)
	#tiles_in_group.append(new_tile)
	add_child(new_tile)
	return new_tile

func create_map():
	var map_size : Vector2i = Vector2i(5, 10)
	var test_map = [[1, 0, 0, 0, 1],
					[1, 1, 0, 0, 1],
					[1, 1, 0, 0, 0],
					[1, 1, 1, 1, 0],
					[1, 1, 1, 0, 0],
					[0, 0, 0, 0, 0],
					[1, 1, 1, 0, 0],
					[0, 0, 0, 0, 0],
					[1, 0, 1, 0, 0],
					[1, 1, 0, 0, 0]]
	
	#map_size = Vector2i(5, 6)
	#test_map = [[0, 0, 0, 0, 0],
	#			[0, 0, 0, 0, 0],
	#			[0, 0, 1, 0, 0],
	#			[0, 0, 0, 0, 0],
	#			[0, 0, 0, 1, 0],
	#			[0, 0, 0, 0, 0]]
	
	step_through_map(test_map, map_size)
	

func step_through_map(map, map_size : Vector2i):
	
	# Set up coordinates to check
	coords_to_check = []
	for x in range(map_size.x):
		for y in range(map_size.y):
			coords_to_check.append(Vector2i(x, y))
			
	
	already_checked = []
	current_building_group = []
	
	# This will loop through the coordinates and create groupings of tiles
	while !coords_to_check.is_empty():
		current_building_group = []
		
		# Once a "1", or tile, is found this will recursively grab all other
		# tiles in the remaining coords_to_check
		process_coord(map, map_size, coords_to_check.pop_front())
		
		# Ensure that all tiles know their respective group
		for t in current_building_group:
			t.tiles_connected_to = current_building_group
		
		# Reclculate edges and local positions now that the tiles know all
		# other tiles in their group
		recalculate_edges(current_building_group)
		recalculate_local_position(current_building_group)
	
func process_coord(map, map_size : Vector2i, coord : Vector2i): #, previous_tile, edge_side):
	if map[coord.y][coord.x] == 0: return
	if map[coord.y][coord.x] == 1:
		var tile_ref = create_tile_at(Vector2i(coord.x, coord.y))
		var x_offset = 640 - ((map_size.x * 32) / 2)
		var y_offset = 360 - ((map_size.y * 32) / 2)
		tile_ref.position = tile_ref.position + Vector2(x_offset, y_offset)
		if test_tile_ref == null: test_tile_ref = tile_ref
		if !current_building_group.has(tile_ref):
			print("appending to group")
			current_building_group.append(tile_ref)
	
	# Check top
	if coord.y - 1 > 0 and coords_to_check.has(Vector2i(coord.x, coord.y - 1)):
		coords_to_check.erase(coord + Vector2i(0, -1))
		process_coord(map, map_size, coord + Vector2i(0, -1))
	# Check right
	if coord.x + 1 < map_size.x and coords_to_check.has(Vector2i(coord.x + 1, coord.y)):
		coords_to_check.erase(coord + Vector2i(1, 0))
		process_coord(map, map_size, coord + Vector2i(1, 0))
	# Check bottom
	if coord.y + 1 < map_size.y and coords_to_check.has(Vector2i(coord.x, coord.y + 1)):
		coords_to_check.erase(coord + Vector2i(0, 1))
		process_coord(map, map_size, coord + Vector2i(0, 1))
	# Check left
	if coord.x - 1 > 0 and coords_to_check.has(Vector2i(coord.x - 1, coord.y)):
		coords_to_check.erase(coord + Vector2i(-1, 0))
		process_coord(map, map_size, coord + Vector2i(-1, 0))
	

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
	
	recalculate_local_position(tile1.tiles_connected_to)
	
	#var smallest : Vector2i
	#smallest = get_smallest_coord(tile1.tiles_connected_to)
	#
	#print("Smallest: (" + str(smallest.x) + ", " + str(smallest.y) +")")
	#
	## use new top left corner to properly set all tiles
	#for t in tile1.tiles_connected_to:
	#	t.local_position += Vector2i(abs(smallest.x), abs(smallest.y))
	
	
	# Re-calculate all edges, see if they need to be turned off
	
	recalculate_edges(tile1.tiles_connected_to)
	
	#var tiles_at : Dictionary
	#for t in tile1.tiles_connected_to:
	#	tiles_at[t.local_position] = true
	#	
	#for t in tile1.tiles_connected_to:
	#	var check 
	#	check = t.local_position + Vector2i(0, -1)
	#	if tiles_at.has(check):
	#		t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.TOP, true)
	#		#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.TOP, true)
	#	check = t.local_position + Vector2i(1, 0)
	#	if tiles_at.has(check):
	#		t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.RIGHT, true)
	#		#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.RIGHT, true)
	#	check = t.local_position + Vector2i(0, 1)
	#	if tiles_at.has(check):
	#		t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.BOTTOM, true)
	#		#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.BOTTOM, true)
	#	check = t.local_position + Vector2i(-1, 0)
	#	if tiles_at.has(check):
	#		t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.LEFT, true)
	#		#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.LEFT, true)
	
	
	print("------------------------------------------")
	
	
	connect_cooldown = 3
	
# Location of cut will use the lower of the two indexes
# i.e. 0 will cut between 0 and 1, 3 will cut between 3 and 4
func cut_tiles(tile_group, direction_of_cut, location_of_cut):
	var new_tile_group1 = []
	var new_tile_group2 = []
	
	for t in tile_group:
		if direction_of_cut == "vertical":
			if t.local_position.x <= location_of_cut:
				new_tile_group1.append(t)
			else:
				new_tile_group2.append(t)
		elif direction_of_cut == "horizontal":
			if t.local_position.y <= location_of_cut:
				new_tile_group1.append(t)
			else:
				new_tile_group2.append(t)
	
	for t in new_tile_group1:
		t.tiles_connected_to = new_tile_group1
		
	for t in new_tile_group2:
		t.tiles_connected_to = new_tile_group2
	
	
	
	for t in new_tile_group1:
		if direction_of_cut == "vertical":
			if t.local_position.x == location_of_cut:
				t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.RIGHT, true)
		elif direction_of_cut == "horizontal":
			if t.local_position.y == location_of_cut:
				t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.BOTTOM, true)
	
	for t in new_tile_group2:
		if direction_of_cut == "vertical":
			if t.local_position.x == location_of_cut + 1:
				t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.LEFT, true)
		elif direction_of_cut == "horizontal":
			if t.local_position.y == location_of_cut + 1:
				t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.TOP, true)
	
	
	recalculate_local_position(new_tile_group1)
	recalculate_local_position(new_tile_group2)
	
	recalculate_edges(new_tile_group1)
	recalculate_edges(new_tile_group2)
	
	ensure_contiguous_group(new_tile_group1)
	ensure_contiguous_group(new_tile_group2)

func get_smallest_coord(tile_group) -> Vector2i:
	var smallest : Vector2i = Vector2i(99999, 99999)
	
	for t in tile_group:
		if smallest.x > t.local_position.x:
			smallest.x = t.local_position.x
		if smallest.y > t.local_position.y:
			smallest.y = t.local_position.y	
	
	
	return smallest


func recalculate_local_position(tile_group):
	var smallest : Vector2i
	smallest = get_smallest_coord(tile_group)
	
	print("Smallest: (" + str(smallest.x) + ", " + str(smallest.y) +")")
	
	# use new top left corner to properly set all tiles
	for t in tile_group:
		t.local_position += Vector2i(smallest.x * -1, smallest.y * -1)
	pass


func recalculate_edges(tile_group):
	var tiles_at : Dictionary
	for t in tile_group:
		tiles_at[t.local_position] = true
		
	for t in tile_group:
		var check 
		check = t.local_position + Vector2i(0, -1)
		if tiles_at.has(check):
			#t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.TOP, true)
			t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.TOP, false)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.TOP, true)
		check = t.local_position + Vector2i(1, 0)
		if tiles_at.has(check):
			#t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.RIGHT, true)
			t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.RIGHT, false)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.RIGHT, true)
		check = t.local_position + Vector2i(0, 1)
		if tiles_at.has(check):
			#t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.BOTTOM, true)
			t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.BOTTOM, false)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.BOTTOM, true)
		check = t.local_position + Vector2i(-1, 0)
		if tiles_at.has(check):
			#t.call_deferred("disable_edge_collision", EdgeComponent.EDGE_SIDE.LEFT, true)
			t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.LEFT, false)
			#t.disable_edge_collision(EdgeComponent.EDGE_SIDE.LEFT, true)
			

# This should go through all tiles in a group and make sure that they are
# actually all in a group

# TODO: make this much more efficient (very bad bigO right now)
func ensure_contiguous_group(tile_group : Array):
	# Start at a tile and check all other reachable tiles, set group, and
	# repeat until initial tilegroup is empty
	var tiles_at : Dictionary
	var tiles_to_check : Array[Vector2i]
	for t in tile_group:
		tiles_at[t.local_position] = t
		tiles_to_check.append(t.local_position)

	# Have starting tile
	# Remove starting tile from tile_group and add to new_group
	# Check all areas adjacent to see if there are tiles there
	# if there are, set those to the next check group
	# take next off the top of the next check group, repeat
	
	while !tile_group.is_empty():
		var new_tile_group : Array = []
		var check_queue : Array = []
		
		check_queue.append(tile_group.pop_front())
		
		while !check_queue.is_empty():
			var t = check_queue.pop_front()
			
			if new_tile_group.has(t): continue
			
			new_tile_group.append(t)
			tile_group.erase(t)
			
			var check
			# Check Top
			check = t.local_position + Vector2i(0, -1)
			if tiles_at.has(check) and !new_tile_group.has(tiles_at[check]):
				check_queue.append(tiles_at[check])
			# Check Right
			check = t.local_position + Vector2i(1, 0)
			if tiles_at.has(check) and !new_tile_group.has(tiles_at[check]):
				check_queue.append(tiles_at[check])
			# Check Bottom
			check = t.local_position + Vector2i(0, 1)
			if tiles_at.has(check) and !new_tile_group.has(tiles_at[check]):
				check_queue.append(tiles_at[check])
			# Check Left
			check = t.local_position + Vector2i(-1, 0)
			if tiles_at.has(check) and !new_tile_group.has(tiles_at[check]):
				check_queue.append(tiles_at[check])
		
		
		# once no more tiles can be reached
		for t in new_tile_group:
			t.tiles_connected_to = new_tile_group
			
		recalculate_local_position(new_tile_group)
		
