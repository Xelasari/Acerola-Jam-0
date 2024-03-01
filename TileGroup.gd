extends Node2D


# Tilegroup aggregates 1-to-many tiles and controls group actions

@export var tileScene : PackedScene

# Contains logical position of each tile in group
class tile_entry:
	var tile : Node
	var x : int
	var y : int

var test_tile_reference

var vector_to_center : Vector2
var being_dragged : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	print("start tilegroup")
	
	#create_tile_at(Vector2i(1, 1))
	#
	#var new_tile = tileScene.instantiate()
	#test_tile_reference = new_tile
	#new_tile.position = Vector2(randi_range(32, 640), randi_range(32, 640))
	#new_tile.connect("start_drag", test2)
	#new_tile.connect("attempt_connection", connect_tile_group)
	#add_child(new_tile)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if being_dragged:
		position = get_global_mouse_position() - vector_to_center
	pass


func create_tile_at(local_coord : Vector2i):
	var new_tile = tileScene.instantiate()
	new_tile.position = local_coord * 32
	new_tile.connect("start_drag", _on_start_drag)
	new_tile.connect("end_drag", _on_end_drag)
	new_tile.connect("attempt_connection", connect_tile_group)
	add_child(new_tile)
	pass


func _on_start_drag(clicked_at):
	var vector_to_center = clicked_at - position
	being_dragged = true
	print("start tilegroup drag")
	

func _on_end_drag():
	being_dragged = false
	print("end tilegroup drag")
	
	
func connect_tile_group(tilegroup : Node):
	var test = tilegroup.get_children()
	tilegroup.call_deferred("remove_child", test[0])
	call_deferred("add_child", test[0])
	print("connect")
	pass
