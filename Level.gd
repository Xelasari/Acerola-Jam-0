extends Node2D

@export var playerScene : PackedScene
@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene

var tileManager
var playerReference

var map_data : Dictionary

var current_level : int

var cuts_remaining : int
var cutsRemainingLabel

var orbs_in_level : int
var orb_counter : int

var restart_cooldown : int

# Called when the node enters the scene tree for the first time.
func _ready():
	#playerReference = $Player
	cutsRemainingLabel = get_node("CutsRemaining")
	
	var tm = tileManagerScene.instantiate()
	tm.connect("load_next_level", _on_load_next_level)
	tm.connect("exit_entered", _on_exit_entered)
	tm.connect("orb_collected", _on_orb_collected)
	tileManager = tm
	add_child(tm)
	
	playerReference = playerScene.instantiate()
	playerReference.connect("player_died", _on_player_died)
	add_child(playerReference)
	
	
	
	#tm.create_map()
	
	#playerReference.position = tm.starting_tile.position + Vector2(16, 16)
	
	load_map_data()
	
	load_level(5)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cutsRemainingLabel.text = "x" + str(cuts_remaining)
	
	if restart_cooldown != 0:
		restart_cooldown -= 1
	
	if Input.is_action_just_pressed("restart"):
		tileManager.call_deferred("clear_map")
		call_deferred("load_level", current_level)
	
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
				
				#print(map_data)
				
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")


func load_level(level_number : int):
	tileManager.create_map(map_data["level_" + str(level_number)])
	playerReference.position = tileManager.starting_tile.position + Vector2(16, 16)
	cuts_remaining = map_data["level_" + str(level_number)]["cuts_allowed"]
	current_level = map_data["level_" + str(level_number)]["current_level"]
	orb_counter = 0
	orbs_in_level = map_data["level_" + str(level_number)]["number_of_orbs"]


func _on_slicer_cut_at(tile_group, direction_of_cut, location_of_cut):
	if tileManager.can_cut(tile_group, direction_of_cut, location_of_cut) and\
		cuts_remaining > 0:
		if $Slicer/SlicerAudioPlayer.playing != true:
			$Slicer/SlicerAudioPlayer.playing = true
		tileManager.cut_tiles(tile_group, direction_of_cut, location_of_cut)
		cuts_remaining -= 1
	
func _on_load_next_level(level_number : int):
	tileManager.call_deferred("clear_map")
	call_deferred("load_level", level_number)
	
	#tileManager.clear_map()
	#load_level(level_number)

func _on_exit_entered(level_number : int):
	#print(orb_counter)
	#print(orbs_in_level)
	if orb_counter == orbs_in_level:
		tileManager.call_deferred("clear_map")
		call_deferred("load_level", level_number)

func _on_orb_collected():
	orb_counter += 1

func _on_player_died():
	if restart_cooldown == 0:
		tileManager.call_deferred("clear_map")
		call_deferred("load_level", current_level)
		restart_cooldown = 3
	#do level reset stuff here
