extends Node2D


@export var tileGroupScene : PackedScene
@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene
@export var levelScene : PackedScene

var tileManager

var levelReference

var levels_cleared : int = 1

# Things to finished before submission
# - Cuts as pick-up-able resources DONE
# - Notes to provide lore breadcrumbs DONE
# - Goal of 20 levels, maybe 25-30 as stretch DONE
# - Start menu + game end screen
# - Music?
# - BUG: Need to have a "last valid position" if overlapping player (maybe can use overlapping tiles fix?)

# Game mechanics to add in:
# - Portals
# - Non-cuttable tiles DONE
# - Orbs/keys to unlock exit DONE (but could add more)
# - Enemies
# - Power lines to do stuff (open door/area, unlock exit)
# - Tile Rotation
# - Hidden areas? (This would likely be very difficult)
# - Buttons that open/close areas

# Bugs to still fix:
# - If you drag a blocking tile ontop of the player, it will softlock the game

# Polish
# - Main menu (play game, level select, credits)
# - Highlight tiles for cut rather than use cursor DONE
# - Add some sort of lore? DONE?
# - Highlight tiles when valid for merging
# - Bring in orbs earlier and use those as breadcrumbs for solving puzzles DONE
# - Highlight tilegroups when hovering/grabbable DONE
# - Maybe add z/x for left and right click?
# - Total levels around 30 maybe? 
# - Movement sliding on walls

# Credit
# - Sound from zapsplat.com

# Called when the node enters the scene tree for the first time.
func _ready():
	var file = FileAccess.open("res://save_data.txt", FileAccess.READ)
	levels_cleared = int(file.get_as_text())
	print(levels_cleared)
	
	$GameMusic.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_start_screen_start_game():
	#$Level.show()
	$StartScreen.hide()
	
	levelReference = levelScene.instantiate()
	levelReference.connect("return_to_title", _on_return_to_title)
	add_child(levelReference)
	levelReference.load_level("level_1")


func _on_start_screen_level_select_menu():
	$StartScreen.hide()
	$LevelSelectScreen.check_if_levels_unlocked(levels_cleared)
	$LevelSelectScreen.show()


func _on_level_select_screen_level_select_button_pressed(level_number):
	$LevelSelectScreen.hide()
	
	levelReference = levelScene.instantiate()
	levelReference.connect("return_to_title", _on_return_to_title)
	add_child(levelReference)
	levelReference.load_level("level_" + str(level_number))


func _on_level_select_screen_return_to_main_menu():
	$StartScreen.show()
	$LevelSelectScreen.hide()


func _on_start_screen_credits_page():
	$StartScreen.hide()
	$CreditsScreen.show()


func _on_credits_screen_return_to_title():
	$StartScreen.show()
	$CreditsScreen.hide()


func _on_return_to_title():
	$StartScreen.show()
	levelReference.queue_free()
	
