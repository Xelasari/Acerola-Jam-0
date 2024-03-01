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

var tiles_in_group : Array

var connect_cooldown : int = 0

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
	if connect_cooldown != 0:
		connect_cooldown -= 1
	pass


func create_tile_at(local_coord : Vector2i):
	var new_tile = tileScene.instantiate()
	new_tile.position = local_coord * 32
	new_tile.local_position = local_coord
	new_tile.connect("start_drag", _on_start_drag)
	new_tile.connect("end_drag", _on_end_drag)
	new_tile.connect("attempt_connection", connect_tile_group)
	tiles_in_group.append(new_tile)
	add_child(new_tile)
	pass

func shift_tiles(shift_vector : Vector2i):
	for tile in tiles_in_group:
		print("should only see this once?")
		tile.position = Vector2(shift_vector * 32)
	pass

func _on_start_drag(clicked_at):
	var vector_to_center = clicked_at - position
	being_dragged = true
	print("start tilegroup drag")
	

func _on_end_drag():
	being_dragged = false
	print("end tilegroup drag")
	
	
func turn_off_all_tiles():
	for tile in tiles_in_group:
		tile.turn_off_edges()
		

func insert_tile(tile : Node, shift_vector : Vector2i):
	tile.position += Vector2(shift_vector * 32)

	
func connect_tile_group(tile : Node, triggered_edge : EdgeComponent.EDGE_SIDE):
	if connect_cooldown != 0: return
		
	
	var tileGroup = tile.get_parent()
	var test = tileGroup.get_children()
	#tileGroup.shift_tiles(Vector2(0, 1))
	#tileGroup.turn_off_all_tiles()
	
	var shift_vector : Vector2i
	shift_vector += tile.local_position
	
	match triggered_edge:
		EdgeComponent.EDGE_SIDE.TOP:
			shift_vector += Vector2i(0, -1)
		EdgeComponent.EDGE_SIDE.BOTTOM:
			shift_vector += Vector2i(0, 1)
		EdgeComponent.EDGE_SIDE.RIGHT:
			shift_vector += Vector2i(1, 0)
		EdgeComponent.EDGE_SIDE.LEFT:
			shift_vector += Vector2i(-1, 0)
			
	#tile.set_edge_collision((triggered_edge + 2) % 4, false)
	#test[0].set_edge_collision(triggered_edge, false)
	
	tile.call_deferred("set_edge_collision", (triggered_edge + 2) % 4, false)
	test[0].call_deferred("set_edge_collision", triggered_edge, false)
	
	
	#call_deferred("turn_off_all_tiles")
	#tileGroup.call_deferred("turn_off_all_tiles")
	insert_tile(test[0], shift_vector)
	tileGroup.call_deferred("remove_child", test[0])
	call_deferred("add_child", test[0])
	print("connect")
	connect_cooldown = 3
	pass
