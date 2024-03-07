extends Node2D


@export var tileGroupScene : PackedScene
@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene

var tileManager


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
# - Highlight tiles for cut rather than use cursor
# - Add some sort of lore?
# - Highlight tiles when valid for merging
# - Bring in orbs earlier and use those as breadcrumbs for solving puzzles
# - Highlight tilegroups when hovering/grabbable
# - Maybe add z/x for left and right click?
# - Total levels around 30 maybe?
# - Movement sliding on walls

# Credit
# - Sound from zapsplat.com

# Called when the node enters the scene tree for the first time.
func _ready():
	#$Level.load_level(1)
	var test : Node
	#$Level.process_mode = Node.PROCESS_MODE_DISABLED
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


