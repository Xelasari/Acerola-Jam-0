extends Node


@export var level_name : String
@export var level_number : int

var map_size : Vector2i = Vector2i(0, 0)

var map_data : Array[Array]

var spawn : Vector2i

var exit : Vector2i

var cuts_allowed : int


var menuButton : MenuButton 

var tileSelector : TILE

enum TILE {
	EMPTY = 0,
	LIGHT_TILE = 1,
	LIGHT_WALL = 2,
	DARK_TILE = 3,
	DARK_WALL = 4	
}

var TileToVectorDict : Dictionary = {
	0 : Vector2i(-1, -1),
	1 : Vector2i(0, 0),
	2 : Vector2i(2, 0),
	3 : Vector2i(1, 0),
	4 : Vector2i(3, 0),
	5 : Vector2i(0, 1),
	6 : Vector2i(1, 1),
	7 : Vector2i(2, 1),
	8 : Vector2i(3, 1),
	9 : Vector2i(0, 2)
}


# Called when the node enters the scene tree for the first time.
func _ready():
	menuButton = $Panel/MenuButton
	menuButton.get_popup().add_item("Clear")
	menuButton.get_popup().add_item("Light Tile")
	menuButton.get_popup().add_item("Light Wall")
	menuButton.get_popup().add_item("Dark Tile")
	menuButton.get_popup().add_item("Dark Wall")
	menuButton.get_popup().add_item("Exit Portal")
	menuButton.get_popup().add_item("Knife")
	menuButton.get_popup().add_item("Orb")
	menuButton.get_popup().add_item("Spawn")
	menuButton.get_popup().add_item("Message")
	var popup = menuButton.get_popup()
	popup.connect("id_pressed", get_tile)
	
	#$Panel/MenuButton.items
	
	
	pass # Replace with function body.

func get_tile(id):
	menuButton.text = menuButton.get_popup().get_item_text(id)
	tileSelector = id
	match id:
		0: pass
		1: pass
		2: pass
		3: pass
		4: pass
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#var input_vector = Input.get_vector("left", "right", "up", "down")
	#$Camera2D.position += input_vector * 500 * delta
	
	#if Input.is_action_just_pressed("left click"):
	#	print($TileMap.local_to_map(get_viewport().get_mouse_position()))
	#	var target_cell = $TileMap.local_to_map(get_viewport().get_mouse_position())
	#	
	#	$TileMap.set_cell(0, target_cell, 0, TileToVectorDict[tileSelector])
	
	if Input.is_action_pressed("right click"):
		var target_cell = $TileMap.local_to_map(get_viewport().get_mouse_position())
		
		if tileSelector == 0:
			$TileMap.set_cell(0, target_cell, 0, TileToVectorDict[tileSelector])
			$ObjectMap.set_cell(0, target_cell, 0, TileToVectorDict[tileSelector])
		elif tileSelector < 5:
			$TileMap.set_cell(0, target_cell, 0, TileToVectorDict[tileSelector])
		else:
			$ObjectMap.set_cell(0, target_cell, 0, TileToVectorDict[tileSelector])
		
		

func read_map_from_json(filename):
	print("Read map from json")
	
	if !FileAccess.file_exists("res://levels/" + str(filename)): return
	
	var map_data : Dictionary
	
	var json = JSON.new()
	var json_as_text = FileAccess.get_file_as_string("res://levels/" + str(filename))
	var json_as_dict = JSON.parse_string(json_as_text)
	
	map_data = json_as_dict
	
	var tileMap : TileMap = $TileMap 
	var objectMap : TileMap = $ObjectMap
	
	tileMap.set_cell(-1, Vector2i(0, 0), 0)
	
	#void set_cell(layer: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0)
	
	for x in range(map_data["map_size"]["x"]):
		for y in range(map_data["map_size"]["y"]):
			#print(map_data["map"][y][x])
			var tile_vector : Vector2i
			match int(map_data["map"][y][x]):
				0: tile_vector = Vector2i(-1, -1)
				1: tile_vector = Vector2i(0, 0)
				2: tile_vector = Vector2i(2, 0)
			#print(tile_vector)
			#tileMap.set_cell(0, Vector2i(x, y), 0, tile_vector)
			
			tileMap.set_cell(0, Vector2i(x, y), 0, TileToVectorDict[int(map_data["map"][y][x])])
	
	var spawn_position = Vector2i(map_data["spawn"]["x"], map_data["spawn"]["y"])
	objectMap.set_cell(0, spawn_position, 0, TileToVectorDict[8])
	
	var exit_position = Vector2i(map_data["exit"]["x"], map_data["exit"]["y"])
	objectMap.set_cell(0, exit_position, 0, TileToVectorDict[5])
	
	for i in range(int(map_data["number_of_knives"])):
		var orb_position = Vector2i(map_data["knife_positions"][i]["x"], map_data["knife_positions"][i]["y"])
		objectMap.set_cell(0, orb_position, 0, TileToVectorDict[6])
	
	for i in range(int(map_data["number_of_orbs"])):
		var orb_position = Vector2i(map_data["orb_positions"][i]["x"], map_data["orb_positions"][i]["y"])
		objectMap.set_cell(0, orb_position, 0, TileToVectorDict[7])
		
	if map_data["has_message"] == true:
		var message_location = Vector2i(map_data["message_location"]["x"], map_data["message_location"]["y"])
		objectMap.set_cell(0, message_location, 0, TileToVectorDict[9])
		$Panel/MessageText.text = map_data["message_text"]
		
	$Panel/LevelName.text = map_data["current_level"] 
	$Panel/NextLevelName.text = map_data["next_level"] 
	
	
	


func write_map_to_json(filename):
	print("Write map to json")
	var save_data = {}
	
	var tileMap : TileMap = $TileMap
	var objectMap : TileMap = $ObjectMap
	var map_start_pos = tileMap.get_used_rect().position
	var tile_map_size = tileMap.get_used_rect().size + tileMap.get_used_rect().position
	
	# test.position
	var test : Rect2i
	print(tileMap.get_used_rect())
	
	save_data["name"] = $Panel/LevelName.text
	
	save_data["map_size"] = {"x" : tile_map_size.x, "y" : tile_map_size.y}
	
	var map : Array[Array]
	
	for y in range(tile_map_size.y):
		var new_row : Array
		for x in range(tile_map_size.x):
			new_row.append(0)
		map.append(new_row)
	
	print(map)
	print(save_data)
	#print(tileMap.get_used_rect())
	print("map_size: " + str(tile_map_size))

	var filled_tiles = tileMap.get_used_cells(0)
	for t in filled_tiles:
		var tileData = tileMap.get_pattern(0, filled_tiles).get_cell_atlas_coords(t - map_start_pos)
		print(tileData)
		var key = TileToVectorDict.find_key(tileData)
		print(key)
		map[t.y][t.x] = key
	pass
	
	var filled_objects = objectMap.get_used_cells(0)
	
	var object_map_start_pos = objectMap.get_used_rect().position
	var object_map_size = objectMap.get_used_rect().size + objectMap.get_used_rect().position
	print("Object section")
	print("Object map position: " + str(objectMap.get_used_rect().position))
	print("Object map size: " + str(objectMap.get_used_rect().size))
	
	print(objectMap.get_used_rect().size)
	print(object_map_size)
	print(tileMap.get_cell_tile_data(1, Vector2i(0, 0)))
	print("Objects: " + str(filled_objects))
	
	var orb_counter : int = 0
	var orb_positions : Array
	
	var knife_counter : int = 0
	var knife_positions : Array
	
	var has_message : bool = false
	var message_location : Dictionary
	var message : String
		
	var spawn_point : Dictionary
	var exit_point : Dictionary
	

	
	for o in filled_objects:
		var objectData = objectMap.get_pattern(0, filled_objects).get_cell_atlas_coords(o - objectMap.get_used_rect().position) 
		print(objectData)
		var key = TileToVectorDict.find_key(objectData)
		print(key)
		if key == 5:
			exit_point = {"x" : o.x, "y" : o.y}
		if key == 6:
			knife_counter += 1
			knife_positions.append({"x" : o.x, "y" : o.y})
		if key == 7:
			orb_counter += 1
			orb_positions.append({"x" : o.x, "y" : o.y})
		if key == 8:
			spawn_point = {"x" : o.x, "y" : o.y}
		if key == 9:
			has_message = true
			message_location = {"x" : o.x, "y" : o.y}
			message = $Panel/MessageText.text
	
	
	print(map)
	save_data["map"] = map
	
	save_data["spawn"] = spawn_point
	save_data["exit"] = exit_point
	
	save_data["number_of_orbs"] = orb_counter
	save_data["orb_positions"] = orb_positions
	
	save_data["number_of_knives"] = knife_counter
	save_data["knife_positions"] = knife_positions
	
	save_data["has_message"] = has_message
	save_data["message_location"] = message_location
	save_data["message_text"] = message
	
	#save_data["cuts_allowed"] = 1
	save_data["current_level"] = $Panel/LevelName.text
	save_data["next_level"] = $Panel/NextLevelName.text
	
	print(save_data)
	
	
	var json_string = JSON.stringify(save_data)
	
	var file = FileAccess.open("res://levels/" + str(filename), FileAccess.WRITE)
	file.store_string(json_string)

func _on_load_button_pressed():
	$TileMap.clear()
	$HoverMap.clear()
	$ObjectMap.clear()
	read_map_from_json($Panel/Filename.text)


func _on_save_button_pressed():
	write_map_to_json($Panel/Filename.text)
