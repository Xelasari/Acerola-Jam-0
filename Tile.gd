extends Node2D

var draggableComponent : DraggableComponent
var movementComponent : MovementComponent
var spriteReference : Sprite2D
var staticBody2DReference : StaticBody2D


var clicked_at : Vector2
var vector_to_center : Vector2

var local_position : Vector2i
var parent_tile_group : Node

# This is used to move all tiles attached to
var tiles_connected_to : Array

# This holds all areas that this tile will slowly drift away from
var areas_to_move_away_from : Array

# This is toggled when a player enters/leaves a tile
var has_player : bool = false

var blocks_player : bool = false

var is_cuttable : bool = true

signal start_drag()
signal end_drag()
signal attempt_connection()
signal connect_two_tiles(tile1, tile2, edge_connecting)
signal queue_connection(tile1, tile2, edge_connecting)
signal dequeue_connection(tile1, tile2)


# Called when the node enters the scene tree for the first time.
func _ready():
	draggableComponent = $DraggableComponent
	movementComponent = $MovementComponent
	spriteReference = $Sprite2D
	staticBody2DReference = $StaticBody2D
	parent_tile_group = get_parent()
	tiles_connected_to.append(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		draggableComponent.being_dragged = false
	$Label.text = str(local_position)
	if draggableComponent.being_dragged:
		var new_pos = get_global_mouse_position() - vector_to_center
		var delta_pos = new_pos - position
		position = new_pos
		propogate_new_position(delta_pos)
		
	if !draggableComponent.being_dragged:
		var vector_to_move : Vector2 = Vector2(0, 0)
		var area_count : int = 1
		var movement_intensity : float = 5.0
		for a in areas_to_move_away_from:
			# This block ensures that dragged groups don't push other tiles away
			var should_skip : bool = false
			for t in a.get_parent().tiles_connected_to:
				if t.draggableComponent.being_dragged: should_skip = true
			if should_skip: continue
			
			# This makes sure player's platform does not move
			if does_group_have_player(): should_skip = true
			if should_skip: continue
			
			# This block ensures that tiles in the same group are not affecting each other
			if tiles_connected_to.has(a):
				should_skip = true
			if should_skip: continue
			
			var p1 : Vector2 = position 
			var p2 : Vector2 = a.get_parent().position
			var rad = p2.angle_to_point(p1)
			
			var d = p1.distance_to(p2)
			
			if d < 50:
				movement_intensity += 30
			elif 50 <= d and d < 60:
				movement_intensity += 20
			elif 65 <= d:
				movement_intensity += 10
			
			
			area_count += 1
			vector_to_move += Vector2.RIGHT.rotated(rad)
			
		
		# TODO: maybe do something more interesting with this, but for now it works
		var final_movement_speed = movement_intensity / area_count
		
		var delta_pos = 5 * delta * vector_to_move
		position += delta_pos
		propogate_new_position(delta_pos)
		
	pass

func propogate_new_position(delta_pos):
	for t in tiles_connected_to:
		if t == self: continue
		t.position += delta_pos


func _on_draggable_component_mouse_entered():
	draggableComponent.is_hovered = true


func _on_draggable_component_mouse_exited():
	draggableComponent.is_hovered = false


func _on_draggable_component_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left click") && draggableComponent.is_hovered && !does_group_have_player():
		draggableComponent.being_dragged = true
		clicked_at = get_global_mouse_position()
		vector_to_center = clicked_at - position
		start_drag.emit(clicked_at)
	# TODO: This might still be buggy
	if Input.is_action_just_released("left click"): # or !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT): # && draggableComponent.is_hovered:
		draggableComponent.being_dragged = false
		#print("Are there any overlapping areas?")
		# on release, use these in tile_manager to check each tile in group, and make a decision to
		# collide there
		#print($LeftEdgeComponent.get_overlapping_areas())
		#print($TopEdgeComponent.get_overlapping_areas())
		#print($RightEdgeComponent.get_overlapping_areas())
		#print($BottomEdgeComponent.get_overlapping_areas())
		
		end_drag.emit()
		attempt_connection.emit()

func _on_edge_component_area_entered(area):
	print("area entered")
	pass # Replace with function body.


func highlight(toggle : bool):
	#$Sprite2D.disable = toggle
	print("highlight or something")
	pass
	

# TODO: this might not be needed anymore
func disable_edge_collision(side : EdgeComponent.EDGE_SIDE, set_value : bool):
	#print("set " + str(side) + " to " + str(set_value))
	match side:
		EdgeComponent.EDGE_SIDE.LEFT:
			$LeftEdgeComponent/CollisionShape2D.disabled = set_value
		EdgeComponent.EDGE_SIDE.TOP:
			$TopEdgeComponent/CollisionShape2D.disabled = set_value
		EdgeComponent.EDGE_SIDE.RIGHT:
			$RightEdgeComponent/CollisionShape2D.disabled = set_value
		EdgeComponent.EDGE_SIDE.BOTTOM:
			$BottomEdgeComponent/CollisionShape2D.disabled = set_value
			
func set_edge_connectivity(side : EdgeComponent.EDGE_SIDE, set_value : bool):
	match side:
		EdgeComponent.EDGE_SIDE.LEFT:
			$LeftEdgeComponent.can_connect = set_value
			if set_value: $ColorLeft.color = Color(0, 1, 0)
			else: $ColorLeft.color = Color(1, 0, 0)
		EdgeComponent.EDGE_SIDE.TOP:
			$TopEdgeComponent.can_connect = set_value
			if set_value: $ColorTop.color = Color(0, 1, 0)
			else: $ColorTop.color = Color(1, 0, 0)
		EdgeComponent.EDGE_SIDE.RIGHT:
			$RightEdgeComponent.can_connect = set_value
			if set_value: $ColorRight.color = Color(0, 1, 0)
			else: $ColorRight.color = Color(1, 0, 0)
		EdgeComponent.EDGE_SIDE.BOTTOM:
			$BottomEdgeComponent.can_connect = set_value
			if set_value: $ColorBottom.color = Color(0, 1, 0)
			else: $ColorBottom.color = Color(1, 0, 0)

func turn_off_edges():
	$LeftEdgeComponent/CollisionShape2D.disabled = true
	$TopEdgeComponent/CollisionShape2D.disabled = true
	$RightEdgeComponent/CollisionShape2D.disabled = true
	$BottomEdgeComponent/CollisionShape2D.disabled = true


# TODO: make these much more clean holy moly
# BUG: This is so messy and likely causing all sorts of problems
# potential fix: since desired behavior is to use mouse release to trigger
# connection, use check_overlapping_bodies() on mouse release and make collision
# decisions then
# Release mouse -> if !check_overlapping_bodies().is_empty() -> find first pair (left-right, top-bottom)
# edges -> connect

func _on_left_edge_component_area_entered(area):

	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		is_group_being_dragged() == true and\
		$LeftEdgeComponent.can_connect == true and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.LEFT)	


func _on_top_edge_component_area_entered(area):

	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		is_group_being_dragged() == true and\
		$TopEdgeComponent.can_connect == true and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.TOP)	



func _on_right_edge_component_area_entered(area):
	
	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		is_group_being_dragged() == true and\
		$RightEdgeComponent.can_connect == true and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.RIGHT)	


func _on_bottom_edge_component_area_entered(area):
	
	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		is_group_being_dragged() == true and\
		$BottomEdgeComponent.can_connect == true and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.TOP:
			
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.BOTTOM)


func edge_entered(source_tile, connecting_tile, edge_connected_on):
	# queue_to_be_connected(source_tile, connecting_tile, edge_connected_on)
	
	queue_connection.emit(source_tile, connecting_tile, edge_connected_on)
	return 
	connect_two_tiles.emit(source_tile, connecting_tile, edge_connected_on)


func _on_left_edge_component_area_exited(area):
	if area.get_collision_layer_value(3) and\
		area.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
		edge_exited(self, area.get_parent())


func _on_top_edge_component_area_exited(area):
	if area.get_collision_layer_value(3) and\
		area.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
		edge_exited(self, area.get_parent())


func _on_right_edge_component_area_exited(area):
	if area.get_collision_layer_value(3) and\
		area.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
		edge_exited(self, area.get_parent())


func _on_bottom_edge_component_area_exited(area):
	if area.get_collision_layer_value(3) and\
		area.edge_side == EdgeComponent.EDGE_SIDE.TOP:
		edge_exited(self, area.get_parent())

func edge_exited(source_tile, connecting_tile):
	dequeue_connection.emit(source_tile, connecting_tile)



func _on_movement_component_update_position(pos):
	position = pos
	pass # Replace with function body.


func _on_repulser_area_entered(area):
	if area.get_collision_layer_value(4): # && !area.get_parent().tiles_connected_to.has(self):
		areas_to_move_away_from.append(area)
	
	# First check if collided area is seperate group
	# if it is, add to overlapping repulser group to calculate new position
	pass # Replace with function body.


func _on_repulser_area_exited(area):
	if areas_to_move_away_from.has(area):
		areas_to_move_away_from.erase(area)
	
	# Use this to remove previously overlapping repulsers
	pass # Replace with function body.


func _on_player_detector_area_entered(area):
	if !is_group_being_dragged():
		has_player = true


func _on_player_detector_area_exited(area):
	if !is_group_being_dragged():
		has_player = false
	
func does_group_have_player() -> bool:
	for t in tiles_connected_to:
		if t.has_player: return true
	return false

func is_group_being_dragged() -> bool:
	for t in tiles_connected_to:
		if t.draggableComponent.being_dragged: return true
	return false


