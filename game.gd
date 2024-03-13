extends Node2D


@export var tileGroupScene : PackedScene
@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene
@export var levelScene : PackedScene

var tileManager

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
	#$StartScreen.process_mode = Node.PROCESS_MODE_PAUSABLE
	#$Level.process_mode = Node.PROCESS_MODE_PAUSABLE
	#$Level.hide()

	#$Level.get_tree().paused = true
	#$Level.paused = true
	#$Level.visible = false
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(get_local_mouse_position())
	#print(get_global_mouse_position())
	pass



func _on_start_screen_start_game():
	print("????")

	#$Level.show()
	$StartScreen.hide()
	
	var level = levelScene.instantiate()
	add_child(level)
	level.load_level("level_1")
	
	#$StartScreen.hide()
	#$StartScreen.get_tree().paused = true
	pass # Replace with function body.


func _on_start_screen_level_select_menu():
	$StartScreen.hide()
	$LevelSelectScreen.show()


func _on_level_select_screen_level_select_button_pressed(level_number):
	$LevelSelectScreen.hide()
	
	var level = levelScene.instantiate()
	add_child(level)
	level.load_level("level_" + str(level_number))


func _on_level_select_screen_return_to_main_menu():
	$StartScreen.show()
	$LevelSelectScreen.hide()
