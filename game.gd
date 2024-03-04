extends Node2D


@export var tileGroupScene : PackedScene
@export var tileManagerScene : PackedScene
@export var slicerScene : PackedScene

var tileManager

# Called when the node enters the scene tree for the first time.
func _ready():
	var tm = tileManagerScene.instantiate()
	tileManager = tm
	add_child(tm)
	
	tm.create_map()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_slicer_cut_at(tile_group, direction_of_cut, location_of_cut):
	tileManager.cut_tiles(tile_group, direction_of_cut, location_of_cut)
