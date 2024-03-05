extends Node2D

@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene

var tileManager
var playerReference

var map_data : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	playerReference = $Player
	
	var tm = tileManagerScene.instantiate()
	tm.connect("load_next_level", _on_load_next_level)
	tileManager = tm
	add_child(tm)
	
	#tm.create_map()
	
	#playerReference.position = tm.starting_tile.position + Vector2(16, 16)
	
	load_map_data()
	
	load_level(1)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_map_data():
	var dir = DirAccess.open("res://levels/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		print(file_name)
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				print("Found file: " + file_name)
				var json = JSON.new()
				var json_as_text = FileAccess.get_file_as_string("res://levels/" + str(file_name))
				var json_as_dict = JSON.parse_string(json_as_text)
				
				map_data[file_name.split(".")[0]] = json_as_dict
				
				print(map_data)
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func load_level(level_number : int):
	tileManager.create_map(map_data["level_" + str(level_number)])
	playerReference.position = tileManager.starting_tile.position + Vector2(16, 16)


func _on_slicer_cut_at(tile_group, direction_of_cut, location_of_cut):
	tileManager.cut_tiles(tile_group, direction_of_cut, location_of_cut)
	
func _on_load_next_level(level_number : int):
	tileManager.call_deferred("clear_map")
	call_deferred("load_level", level_number)
	
	#tileManager.clear_map()
	#load_level(level_number)

