extends Node2D

var draggableComponent : DraggableComponent
var movementComponent : MovementComponent
var spriteReference : Sprite2D
var staticBody2DReference : StaticBody2D


var clicked_at : Vector2
var vector_to_center : Vector2

var local_position : Vector2i
var parent_tile_group : Node


var connection_attempted : bool = false
var position_drag_check : bool = false
var position_before_drag : Vector2

# This is used to move all tiles attached to
var tiles_connected_to : Array

# This holds all areas that this tile will slowly drift away from
var areas_to_move_away_from : Array

# This is toggled when a player enters/leaves a tile
var has_player : bool = false
var cached_player_tile : Node = null

var blocks_player : bool = false

var is_cuttable : bool = true

var is_overlapping : bool = false

var areas_overlapping : Array


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
	#if is_group_overlapping():
	#	spriteReference.modulate = Color(0, 1, 0)
	#else: 
	#	spriteReference.modulate = Color(1, 0, 0)
		
	if draggableComponent.being_dragged and !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		draggableComponent.being_dragged = false
		
		
	if draggableComponent.is_hovered and !does_group_have_player():
		for t in tiles_connected_to:
			if t.get_node("LeftEdgeComponent").can_connect:
				t.get_node("ColorLeft").color = Color(1, 1, 1, 1)
			if t.get_node("TopEdgeComponent").can_connect:
				t.get_node("ColorTop").color = Color(1, 1, 1, 1)
			if t.get_node("RightEdgeComponent").can_connect:
				t.get_node("ColorRight").color = Color(1, 1, 1, 1)
			if t.get_node("BottomEdgeComponent").can_connect:
				t.get_node("ColorBottom").color = Color(1, 1, 1, 1)
			pass
		# Do something with Color/left/right/etc to highlight to green? Or white maybe
	
	$Label.text = str(local_position)
	if draggableComponent.being_dragged:
		var new_pos = get_global_mouse_position() - vector_to_center
		var delta_pos = new_pos - position
		position = new_pos
		propogate_new_position(delta_pos)
	
	
	# BUG: This causes so much lag, need to figure out a good way to optimize it
	# Maybe do a pre-check that checks to see if 
	
	if !draggableComponent.being_dragged:
		var vector_to_move : Vector2 = Vector2(0, 0)
		var area_count : int = 1
		var movement_intensity : float = 5.0
		for a : Area2D in areas_to_move_away_from:
			if a.get_parent().tiles_connected_to.has(self):
				continue
			
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
		if delta_pos != Vector2.ZERO:
			position += delta_pos
			propogate_new_position(delta_pos)
	
	var c
	c = $ColorRight.get_color()
	if c.a > 0:
		var new_color = Color(c.r, c.g, c.b, c.a - 0.05)
		$ColorRight.set_color(new_color)
	c = $ColorBottom.get_color()
	if c.a > 0:
		var new_color = Color(c.r, c.g, c.b, c.a - 0.05)
		$ColorBottom.set_color(new_color)
	c = $ColorTop.get_color()
	if c.a > 0:
		var new_color = Color(c.r, c.g, c.b, c.a - 0.05)
		$ColorTop.set_color(new_color)
	c = $ColorLeft.get_color()
	if c.a > 0:
		var new_color = Color(c.r, c.g, c.b, c.a - 0.05)
		$ColorLeft.set_color(new_color)

func propogate_new_position(delta_pos):
	for t in tiles_connected_to:
		if t == self: continue
		t.position += delta_pos


func _on_draggable_component_mouse_entered():
	#$Sprite2D.modulate = Color(0, 1, 0)
	draggableComponent.is_hovered = true


func _on_draggable_component_mouse_exited():
	#$Sprite2D.modulate = Color(1, 0, 0)
	draggableComponent.is_hovered = false


func _on_draggable_component_input_event(viewport, event, shape_idx):
	if Input.is_action_just_pressed("left click") && draggableComponent.is_hovered && !does_group_have_player():
		draggableComponent.being_dragged = true
		position_drag_check = true
		position_before_drag = position
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
			#if set_value: $ColorLeft.color = Color(0, 1, 0)
			#else: $ColorLeft.color = Color(1, 0, 0)
		EdgeComponent.EDGE_SIDE.TOP:
			$TopEdgeComponent.can_connect = set_value
			#if set_value: $ColorTop.color = Color(0, 1, 0)
			#else: $ColorTop.color = Color(1, 0, 0)
		EdgeComponent.EDGE_SIDE.RIGHT:
			$RightEdgeComponent.can_connect = set_value
			#if set_value: $ColorRight.color = Color(0, 1, 0)
			#else: $ColorRight.color = Color(1, 0, 0)
		EdgeComponent.EDGE_SIDE.BOTTOM:
			$BottomEdgeComponent.can_connect = set_value
			#if set_value: $ColorBottom.color = Color(0, 1, 0)
			#else: $ColorBottom.color = Color(1, 0, 0)

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
		is_group_overlapping() == false and\
		is_group_being_dragged() == true and\
		$LeftEdgeComponent.can_connect == true and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.LEFT)	


func _on_top_edge_component_area_entered(area):

	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		is_group_overlapping() == false and\
		is_group_being_dragged() == true and\
		$TopEdgeComponent.can_connect == true and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.TOP)	



func _on_right_edge_component_area_entered(area):

	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		is_group_overlapping() == false and\
		is_group_being_dragged() == true and\
		$RightEdgeComponent.can_connect == true and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.RIGHT)	


func _on_bottom_edge_component_area_entered(area):

	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		is_group_overlapping() == false and\
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
	
	
func _on_tile_detector_area_entered(area):
	#if is_group_being_dragged():
	is_overlapping = true
	areas_overlapping.append(area)


func _on_tile_detector_area_exited(area):
	is_overlapping = false
	areas_overlapping.erase(area)
	
	
func does_group_have_player() -> bool:
	if cached_player_tile != null:
		if cached_player_tile.has_player: return true
		
	for t in tiles_connected_to:
		if t.has_player:
			cached_player_tile = t
			return true
	return false

func is_group_being_dragged() -> bool:
	for t in tiles_connected_to:
		if t.draggableComponent.being_dragged: return true
	return false
	
func is_group_overlapping() -> bool:
	for t in tiles_connected_to:
		if !t.areas_overlapping.is_empty(): return true
	return false


# takes a tile and a direction and highlights all edges along that line
func turn_on_highlight_line(area, direction):
	if direction == "vertical":
		for t in tiles_connected_to:
			if area.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
				$ColorRight.color = Color(0, 0, 0, 1)
			if area.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
				$ColorLeft.color = Color(0, 0, 0, 1)
	if direction == "horizontal":
		for t in tiles_connected_to:
			if area.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
				$ColorBottom.color = Color(0, 0, 0, 1)
			if area.edge_side == EdgeComponent.EDGE_SIDE.TOP:
				$ColorTop.color = Color(0, 0, 0, 1)
	
func turn_off_highlight_line(area, direction):
	#if direction == "vertical":
	for t in tiles_connected_to:
		if area.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
			$ColorRight.color = Color(0, 0, 0, 0)
		if area.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
			$ColorLeft.color = Color(0, 0, 0, 0)
	#if direction == "horizontal":
	for t in tiles_connected_to:
		if area.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
			$ColorBottom.color = Color(0, 0, 0, 0)
		if area.edge_side == EdgeComponent.EDGE_SIDE.TOP:
			$ColorTop.color = Color(0, 0, 0, 0)

func has_coord_in_group(coord : Vector2i):
	for t in tiles_connected_to:
		if t.local_position == coord: return true
	return false



