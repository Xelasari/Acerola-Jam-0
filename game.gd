extends Node2D


@export var tileGroupScene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var tgs = tileGroupScene.instantiate()
	tgs.position = Vector2(32, 32)
	tgs.create_tile_at(Vector2i(0, 0))
	add_child(tgs)
	
	tgs = tileGroupScene.instantiate()
	tgs.position = Vector2(320, 320)
	tgs.create_tile_at(Vector2i(0, 0))
	add_child(tgs)
	
	tgs = tileGroupScene.instantiate()
	tgs.position = Vector2(0, 320)
	tgs.create_tile_at(Vector2i(0, 0))
	add_child(tgs)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
