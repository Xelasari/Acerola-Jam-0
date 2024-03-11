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


@export var tileScene : PackedScene
@export var exitPointScene : PackedScene
@export var knifeScene : PackedScene
@export var orbScene : PackedScene
@export var messageScene : PackedScene

var connect_cooldown : int = 0
var connection_queue = []


var dragging_allowed : bool = true


var check_next : Array[Vector2i]
var already_checked : Array[Vector2i]
var coords_to_check : Array[Vector2i]
var current_building_group : Array


var points_of_interest : Dictionary = {}

# This points at the tile to spawn the player in
var starting_tile : Node = null


var current_level : String
var next_level : String


signal load_next_level(level_name : String)
signal exit_entered(level_name : String)
signal orb_collected()
signal knife_collected()


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
	
	#print("Creating tile at: " + str(new_tile.position))
	new_tile.local_position = local_coord
	#new_tile.connect("start_drag", _on_start_drag)
	#new_tile.connect("end_drag", _on_end_drag)
	new_tile.connect("attempt_connection", _on_attempt_connection)
	#new_tile.connect("connect_two_tiles", _on_connect_two_tiles)
	new_tile.connect("queue_connection", _on_queue_connection)
	new_tile.connect("dequeue_connection", _on_dequeue_connection)
	#tiles_in_group.append(new_tile)
	# BUG: Why is add_child causing a printout in output?
	add_child(new_tile)
	return new_tile


func clear_map():
	for n in get_children():
		remove_child(n)
		n.queue_free()


func create_map(map_data : Dictionary):
	points_of_interest.clear()
	var map_size : Vector2i = Vector2i(5, 10)
	var test_map = [[1, 0, 0, 0, 1],
					[1, 1, 0, 0, 1],
					[1, 1, 0, 0, 0],
					[1, 1, 2, 1, 0],
					[1, 1, 2, 0, 0],
					[0, 0, 0, 0, 0],
					[1, 1, 1, 0, 0],
					[0, 0, 0, 0, 0],
					[1, 0, 1, 0, 0],
					[1, 1, 0, 0, 0]]
	
	
	current_level = map_data["current_level"]
	next_level = map_data["next_level"]
	points_of_interest["spawn"] = Vector2i(map_data["spawn"].x, map_data["spawn"].y)
	points_of_interest["exit"] = Vector2i(map_data["exit"].x, map_data["exit"].y)
	points_of_interest["number_of_knives"] = map_data["number_of_knives"]
	points_of_interest["knife_positions"] = []
	for i in range(points_of_interest["number_of_knives"]):
		points_of_interest["knife_positions"].append(Vector2i(map_data["knife_positions"][i]["x"], map_data["knife_positions"][i]["y"]))
	points_of_interest["number_of_orbs"] = map_data["number_of_orbs"]
	points_of_interest["orb_positions"] = []
	for i in range(points_of_interest["number_of_orbs"]):
		points_of_interest["orb_positions"].append(Vector2i(map_data["orb_positions"][i]["x"], map_data["orb_positions"][i]["y"]))
	points_of_interest["has_message"] = false
	if map_data["has_message"]:
		points_of_interest["has_message"] = true
		points_of_interest["message_location"] = Vector2i(map_data["message_location"].x, map_data["message_location"].y)
		points_of_interest["message_text"] = map_data["message_text"]
		
	
	#map_size = Vector2i(5, 6)
	#test_map = [[0, 0, 0, 0, 0],
	#			[0, 0, 0, 0, 0],
	#			[0, 0, 1, 0, 0],
	#			[0, 0, 0, 0, 0],
	#			[0, 0, 0, 1, 0],
	#			[0, 0, 0, 0, 0]]
	
	map_size = Vector2i(map_data["map_size"]["x"], map_data["map_size"]["y"])
	
	step_through_map(map_data["map"], map_size)
	

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
	if map[coord.y][coord.x] != 0:
		var tile_ref = create_tile_at(Vector2i(coord.x, coord.y))
		var x_offset = 640 - ((map_size.x * 32) / 2)
		var y_offset = 360 - ((map_size.y * 32) / 2)
		tile_ref.position = tile_ref.position + Vector2(x_offset, y_offset)
		if map[coord.y][coord.x] == 2:
			tile_ref.blocks_player = true
			tile_ref.is_cuttable = true
			tile_ref.spriteReference.texture = load("res://assets/wall_light.png")
			tile_ref.staticBody2DReference.set_collision_layer_value(7, true)
		if map[coord.y][coord.x] == 3:
			tile_ref.blocks_player = false
			tile_ref.is_cuttable = false
			tile_ref.spriteReference.texture = load("res://assets/checker_tile_dark.png")
		if map[coord.y][coord.x] == 4:
			tile_ref.blocks_player = true
			tile_ref.is_cuttable = false
			tile_ref.spriteReference.texture = load("res://assets/wall_dark.png")
			tile_ref.staticBody2DReference.set_collision_layer_value(7, true)
		if coord.x == points_of_interest["spawn"].x && coord.y == points_of_interest["spawn"].y:
			starting_tile = tile_ref
		if coord.x == points_of_interest["exit"].x && coord.y == points_of_interest["exit"].y:
			var exit_point = exitPointScene.instantiate()
			exit_point.connect("player_entered_exit", _on_player_entered_exit)
			tile_ref.add_child(exit_point)
		for i in range(points_of_interest["number_of_knives"]):
			if coord.x == points_of_interest["knife_positions"][i].x and coord.y == points_of_interest["knife_positions"][i].y:
				var knife = knifeScene.instantiate()
				knife.connect("player_touched_knife", _on_player_touched_knife)
				tile_ref.add_child(knife)
		for i in range(points_of_interest["number_of_orbs"]):
			if coord.x == points_of_interest["orb_positions"][i].x and coord.y == points_of_interest["orb_positions"][i].y:
				var orb = orbScene.instantiate()
				orb.connect("player_touched_orb", _on_player_touched_orb)
				tile_ref.add_child(orb)
		if points_of_interest["has_message"]:
			if coord.x == points_of_interest["message_location"].x && coord.y == points_of_interest["message_location"].y:
				var msg = messageScene.instantiate()
				msg.set_message_text(points_of_interest["message_text"])
				tile_ref.add_child(msg)
		if !current_building_group.has(tile_ref):
			#print("appending to group")
			current_building_group.append(tile_ref)
	
	# Check top
	if coord.y - 1 >= 0 and coords_to_check.has(Vector2i(coord.x, coord.y - 1)):
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
	if coord.x - 1 >= 0 and coords_to_check.has(Vector2i(coord.x - 1, coord.y)):
		coords_to_check.erase(coord + Vector2i(-1, 0))
		process_coord(map, map_size, coord + Vector2i(-1, 0))
	

func _on_queue_connection(tile1, tile2, edge_side):
	var connection_entry = {}
	
	#print("queue connection")
	
	connection_entry["tile1"] = tile1
	connection_entry["tile2"] = tile2
	connection_entry["edge_side"] = edge_side
	
	connection_queue.append(connection_entry)
	
	
func _on_dequeue_connection(tile1, tile2):
	for item in connection_queue:
		if item["tile1"] == tile1 && item["tile2"] == tile2:
			connection_queue.erase(item)
			break
			

# BUG: Need to have a way to ensure that tiles can't be overlapping when attempting to connect
# BUG: Maybe refine this to find the closest two connections and use that
func _on_attempt_connection():
	if connect_cooldown != 0:
		connection_queue.clear()
		return
	if connection_queue.is_empty(): return
	#var connection = connection_queue.pop_front()
	
	var closest_connection
	var closest_distance : float = 9999999999
	
	for c in connection_queue:
		if c["tile1"].position.distance_to(c["tile2"].position) < closest_distance:
			closest_connection = c
			closest_distance = c["tile1"].position.distance_to(c["tile2"].position)
	
	_on_connect_two_tiles(closest_connection["tile1"], closest_connection["tile2"], closest_connection["edge_side"])
	connection_queue.clear()
		


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
			shift_vector = tile1.local_position - tile2.local_position
			shift_vector += Vector2i(0, 1)
		EdgeComponent.EDGE_SIDE.RIGHT:
			shift_vector = tile1.local_position - tile2.local_position
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
	var old_tile_group1 : Array = tile1.tiles_connected_to
	var old_tile_group2 : Array = tile2.tiles_connected_to
	
	
	
	# using tile1, set new positions for clean tiling
	
	# BUG: This might be causing the strange shift, need more data though
	# This definitely is the issue, may need to use a small shift (ie some value between 
	
	if old_tile_group1[0].does_group_have_player(): print("Group 1 has player")
	if old_tile_group2[0].does_group_have_player(): print("Group 2 has player")
	
	if !old_tile_group1[0].does_group_have_player():
		var reference_pos = tile2.position - Vector2(tile2.local_position * 32)
		for t in old_tile_group1:
			t.position = (reference_pos + Vector2((t.local_position * 32)))
	else:
		var reference_pos = tile1.position - Vector2(tile1.local_position * 32)
		for t in old_tile_group2:
			t.position = (reference_pos + Vector2((t.local_position * 32)))

	
	for t in tile1.tiles_connected_to:
		new_tiles_connected_to.append(t)
	
	for t in tile2.tiles_connected_to:
		new_tiles_connected_to.append(t)
		
	for t in new_tiles_connected_to:
		t.tiles_connected_to = new_tiles_connected_to
		
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
	
func can_cut(tile_group, direction_of_cut, location_of_cut) -> bool:
	# Need to add a loop here that checks if it is a valid cut
	# An invalid cut would be anywhere the cut tries to take apart 2 dark tiles
	var tiles_at : Dictionary
	for t in tile_group:
		tiles_at[t.local_position] = t
		
	for t in tile_group:
		if direction_of_cut == "vertical":
			if t.local_position.x == location_of_cut.x:
				if tiles_at.has(t.local_position) and tiles_at.has(t.local_position + Vector2i(1, 0)):
					if !tiles_at[t.local_position].is_cuttable and !tiles_at[t.local_position + Vector2i(1, 0)].is_cuttable:
						return false
		
		if direction_of_cut == "horizontal":
			if t.local_position.y == location_of_cut.y:
				if tiles_at.has(t.local_position) and tiles_at.has(t.local_position + Vector2i(0, 1)):
					if !tiles_at[t.local_position].is_cuttable and !tiles_at[t.local_position + Vector2i(0, 1)].is_cuttable:
						return false
	
	return true
	
# Location of cut will use the lower of the two indexes
# i.e. 0 will cut between 0 and 1, 3 will cut between 3 and 4
func cut_tiles(tile_group, direction_of_cut, location_of_cut):
	var new_tile_group1 = []
	var new_tile_group2 = []
	
	# Get bounds originating from cut
	if direction_of_cut == "vertical":
		# need to check y coords, up and down,
		var done_checking : bool = false
		var lower_bound : int
		var upper_bound : int
		var check_point : int 
		
		check_point = location_of_cut.y
		while(!done_checking):
			if tile_group[0].has_coord_in_group(Vector2i(location_of_cut.x, check_point)):
				lower_bound = check_point
				check_point -= 1
			else: done_checking = true
			
		done_checking = false
		
		check_point = location_of_cut.y
		while(!done_checking):
			if tile_group[0].has_coord_in_group(Vector2i(location_of_cut.x, check_point)):
				upper_bound = check_point
				check_point += 1
			else: done_checking = true
			
		print("Bounds: [" + str(lower_bound) + ", " + str(upper_bound) + "]")
	
	for t in tile_group:
		if direction_of_cut == "vertical":
			if t.local_position.x <= location_of_cut.x:
				new_tile_group1.append(t)
			else:
				new_tile_group2.append(t)
		elif direction_of_cut == "horizontal":
			if t.local_position.y <= location_of_cut.y:
				new_tile_group1.append(t)
			else:
				new_tile_group2.append(t)
	
	for t in new_tile_group1:
		t.tiles_connected_to = new_tile_group1
		# Recalculate player tile
		t.cached_player_tile = null
		t.does_group_have_player()
		
	for t in new_tile_group2:
		t.tiles_connected_to = new_tile_group2
		# Recalculate player tile
		t.cached_player_tile = null
		t.does_group_have_player()
	
	
	for t in new_tile_group1:
		if direction_of_cut == "vertical":
			if t.local_position.x == location_of_cut.x:
				t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.RIGHT, true)
		elif direction_of_cut == "horizontal":
			if t.local_position.y == location_of_cut.y:
				t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.BOTTOM, true)
	
	for t in new_tile_group2:
		if direction_of_cut == "vertical":
			if t.local_position.x == location_of_cut.x + 1:
				t.set_edge_connectivity(EdgeComponent.EDGE_SIDE.LEFT, true)
		elif direction_of_cut == "horizontal":
			if t.local_position.y == location_of_cut.y + 1:
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
	
	#print("Smallest: (" + str(smallest.x) + ", " + str(smallest.y) +")")
	
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
			t.cached_player_tile = null
			t.does_group_have_player()
		
		recalculate_local_position(new_tile_group)
		recalculate_edges(new_tile_group)
		

func _on_player_entered_exit():
	print("Yippie")
	#load_next_level.emit(next_level)
	exit_entered.emit(next_level)
	
func _on_player_touched_orb():
	print("Orb Collected")
	orb_collected.emit()
	
func _on_player_touched_knife():
	print("Knife Collected")
	knife_collected.emit()
