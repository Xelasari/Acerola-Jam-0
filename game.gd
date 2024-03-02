extends Node2D


@export var tileGroupScene : PackedScene
@export var tileManager : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	#var tgs = tileGroupScene.instantiate()
	#tgs.position = Vector2(32, 32)
	#tgs.create_tile_at(Vector2i(0, 0))
	#add_child(tgs)
	#
	#tgs = tileGroupScene.instantiate()
	#tgs.position = Vector2(320, 320)
	#tgs.create_tile_at(Vector2i(0, 0))
	#add_child(tgs)
	#
	#tgs = tileGroupScene.instantiate()
	#tgs.position = Vector2(0, 320)
	#tgs.create_tile_at(Vector2i(0, 0))
	#add_child(tgs)
	#pass # Replace with function body.
	
	var tm = tileManager.instantiate()
	
	#for x in range(0, 10):
	#	for y in range(0, 10):
	#		tm.create_tile_at(Vector2i(x, y))
	
	
	
	#tm.create_tile_at(Vector2i(0, 0))
	#tm.create_tile_at(Vector2i(2, 2))
	#tm.create_tile_at(Vector2i(4, 4))
	#
	#tm.create_tile_at(Vector2i(5, 0))
	#tm.create_tile_at(Vector2i(5, 2))
	#tm.create_tile_at(Vector2i(5, 4))
	#
	#tm.create_tile_at(Vector2i(5, 7))
	#tm.create_tile_at(Vector2i(5, 9))
	#tm.create_tile_at(Vector2i(5, 11))
	add_child(tm)
	
	tm.create_map()
	pass
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass




