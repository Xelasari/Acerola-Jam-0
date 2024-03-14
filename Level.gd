extends Node2D

@export var playerScene : PackedScene
@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene

var tileManager
var playerReference
var backgroundReference

var map_data : Dictionary

var current_level : String

var cuts_remaining : int
var cutsRemainingLabel

var orbs_in_level : int
var orb_counter : int

var restart_cooldown : int

var boom_counter : float = 0
var boom_threshold : float = 5

var selected_tool : String = "hand"

signal return_to_title()


# Called when the node enters the scene tree for the first time.
func _ready():
	#playerReference = $Player
	cutsRemainingLabel = get_node("KnifeGroup/CutsRemaining")
	var tm = tileManagerScene.instantiate()
	tm.connect("load_next_level", _on_load_next_level)
	tm.connect("exit_entered", _on_exit_entered)
	tm.connect("orb_collected", _on_orb_collected)
	tm.connect("knife_collected", _on_knife_collected)
	tileManager = tm
	add_child(tm)
	
	playerReference = playerScene.instantiate()
	playerReference.connect("player_died", _on_player_died)

	add_child(playerReference)
	
	backgroundReference = get_parent().get_node("Background")
	backgroundReference.set_player_reference(playerReference)
	
	
	
	#tm.create_map()
	
	#playerReference.position = tm.starting_tile.position + Vector2(16, 16)
	
	load_map_data()
	
	#load_level("level_1")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cutsRemainingLabel.text = "x" + str(cuts_remaining)
	
	boom_counter += delta
	if boom_counter > boom_threshold:
		$Boom.play()
		boom_counter -= boom_threshold
	
	if restart_cooldown != 0:
		restart_cooldown -= 1
	
	if Input.is_action_just_pressed("restart"):
		tileManager.call_deferred("clear_map")
		call_deferred("load_level", current_level)
	
	if Input.is_action_just_pressed("esc"):
		if $EscMenu.visible:
			$EscMenu.hide()
		else:
			$EscMenu.show()
	
	var level_number = int(current_level.split("_")[1])
	
	if Input.is_action_just_pressed("swap"):
		if selected_tool == "hand" and level_number > 15:
			selected_tool = "knife"
		elif selected_tool == "knife" and level_number > 15:
			selected_tool = "hand"
	
	
	if level_number > 10 and selected_tool == "hand":
		$HandGroup.visible = true
	else:
		$HandGroup.visible = false
	
	if level_number > 15 and selected_tool == "knife":
		$KnifeGroup.visible = true
	else:
		$KnifeGroup.visible = false
	
	
	if level_number == 30:
		backgroundReference.toggle_eye_tracking(true)
		backgroundReference.eye_track_player()


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


func load_level(level_name : String):
	if level_name == "return_to_menu":
		if !get_parent().get_node("GameMusic").playing:
			get_parent().get_node("GameMusic").play()
		
		backgroundReference.set_blackhole_scale(0)
		backgroundReference.set_eye_scale(0)
		return_to_title.emit()
		return
	
	tileManager.create_map(map_data[level_name])
	playerReference.position = tileManager.starting_tile.position + Vector2(16, 16)
	#cuts_remaining = map_data["level_" + str(level_number)]["cuts_allowed"]
	cuts_remaining = 0
	#current_level = map_data["level_" + str(level_number)]["current_level"]
	current_level = map_data[level_name]["current_level"]
	orb_counter = 0
	orbs_in_level = map_data[level_name]["number_of_orbs"]
	var pretty_name : String
	pretty_name = level_name.split("_")[0].capitalize() + " " + level_name.split("_")[1]
	var level_number = int(level_name.split("_")[1])
	$LevelName.text = pretty_name
	print(level_number)
	
	if get_parent().levels_cleared < int(current_level):
		get_parent().levels_cleared = int(current_level)
		var file = FileAccess.open("res://save_data.txt", FileAccess.WRITE)
		file.store_string(current_level)
	
	# needs to go from 1 to 4
	var scale_factor
	# 1 + 3 (
	
	if level_number > 15:
		$HandGroup/Hints.text = "E: Swap\nLMB: Drag Tiles"
	else:
		$HandGroup/Hints.text = "\nLMB: Drag Tiles"
		
	
	
	
	if level_number == 30:
		get_parent().get_node("GameMusic").stop()
		playerReference.toggle_footsteps(false)
		boom_counter = 0
		boom_threshold = 9999999999
	else:
		if !get_parent().get_node("GameMusic").playing:
			get_parent().get_node("GameMusic").play()
		playerReference.toggle_footsteps(true)
		boom_threshold = 1 + (5 * (1 - (level_number / 30.0)))
		$Boom.volume_db = -20 + (20 * (level_number / 30.0))
	
	print(boom_threshold)
	backgroundReference.set_blackhole_scale(level_number)
	#$Background/Blackhole.scale = Vector2(4.0, 4.0) * ((1 + float((level_number * 3) / 30.0)))
	#print($Background/Blackhole.scale)
	match level_number:
		26:
			backgroundReference.set_eye_stage(1)
			backgroundReference.set_eye_scale(level_number)
			
			#$Background/Eye.visible = true
			#$Background/Eye.texture = load("res://assets/eye_1.png")
			#$Background/Eye.scale = Vector2(4.0, 4.0) * (4.0 * float(level_number / 30.0))
			#$Background/Eye.modulate = Color(1, 1, 1, 0.2)
		27:
			backgroundReference.set_eye_stage(2)
			backgroundReference.set_eye_scale(level_number)
			
			#$Background/Eye.visible = true
			#$Background/Eye.texture = load("res://assets/eye_2.png")
			#$Background/Eye.scale = Vector2(4.0, 4.0) * (4.0 * float(level_number / 30.0))
			#$Background/Eye.modulate = Color(1, 1, 1, 0.4)
		28:
			backgroundReference.set_eye_stage(3)
			backgroundReference.set_eye_scale(level_number)
			
			#$Background/Eye.visible = true
			#$Background/Eye.texture = load("res://assets/eye_3.png")
			#$Background/Eye.scale = Vector2(4.0, 4.0) * (4.0 * float(level_number / 30.0))
			#$Background/Eye.modulate = Color(1, 1, 1, 0.6)
		29:
			backgroundReference.set_eye_stage(4)
			backgroundReference.set_eye_scale(level_number)
			
			#$Background/Eye.visible = true
			#$Background/Eye.texture = load("res://assets/eye_4.png")
			#$Background/Eye.scale = Vector2(4.0, 4.0) * (4.0 * float(level_number / 30.0))
			#$Background/Eye.modulate = Color(1, 1, 1, 0.8)
		30:
			backgroundReference.set_eye_stage(5)
			backgroundReference.set_eye_scale(level_number)
			
			#$Background/Eye.visible = true
			#$Background/Eye.texture = load("res://assets/eye_5.png")
			#$Background/Eye.scale = Vector2(4.0, 4.0) * (4.0 * float(level_number / 30.0))
			#$Background/Eye.modulate = Color(1, 1, 1, 1)
		_:
			backgroundReference.set_eye_stage(0)
			#$Background/Eye.visible = false

func _on_slicer_cut_at(tile_group, direction_of_cut, location_of_cut):
	if tileManager.can_cut(tile_group, direction_of_cut, location_of_cut) and\
		cuts_remaining > 0:
		$Slicer/SlicerAudioPlayer.play()
		#if $Slicer/SlicerAudioPlayer.playing != true:
		#	$Slicer/SlicerAudioPlayer.playing = true
		tileManager.cut_tiles(tile_group, direction_of_cut, location_of_cut)
		cuts_remaining -= 1
	
func _on_load_next_level(level_name : String):
	tileManager.call_deferred("clear_map")
	call_deferred("load_level", level_name)
	
	#tileManager.clear_map()
	#load_level(level_number)

func _on_exit_entered(level_name : String):
	#print(orb_counter)
	#print(orbs_in_level)
	if orb_counter == orbs_in_level:
		tileManager.call_deferred("clear_map")
		call_deferred("load_level", level_name)

func _on_orb_collected():
	$OrbAudio.play()
	orb_counter += 1
	
func _on_knife_collected():
	cuts_remaining += 1

func _on_player_died():
	if restart_cooldown == 0:
		tileManager.call_deferred("clear_map")
		call_deferred("load_level", current_level)
		restart_cooldown = 3
	#do level reset stuff here


func _on_esc_menu_return_to_title():
	backgroundReference.set_blackhole_scale(0)
	backgroundReference.set_eye_scale(0)
	return_to_title.emit()
