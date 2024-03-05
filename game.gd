extends Node2D


@export var tileGroupScene : PackedScene
@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene

var tileManager


# Game mechanics to add in:
# - Portals
# - Non-cuttable tiles
# - Orbs/keys to unlock exit
# - Enemies
# - Power lines to do stuff (open door/area, unlock exit)

# Bugs to still fix:
# - If you drag a blocking tile ontop of the player, it will softlock the game


# Called when the node enters the scene tree for the first time.
func _ready():
	#$Level.load_level(1)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


