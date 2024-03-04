extends Node2D

var draggableComponent : DraggableComponent
var movementComponent : MovementComponent


var clicked_at : Vector2
var vector_to_center : Vector2

var local_position : Vector2i
var parent_tile_group : Node

# This is used to move all tiles attached to
var tiles_connected_to : Array

# This holds all areas that this tile will slowly drift away from
var areas_to_move_away_from : Array


signal start_drag()
signal end_drag()
signal attempt_connection(area, triggered_side)
signal connect_two_tiles(tile1, tile2)

# Called when the node enters the scene tree for the first time.
func _ready():
	draggableComponent = $DraggableComponent
	movementComponent = $MovementComponent
	parent_tile_group = get_parent()
	tiles_connected_to.append(self)
	return
	var e : EdgeComponent
	e = EdgeComponent.new()
	e.create_edge(EdgeComponent.EDGE_SIDE.TOP)
	e.connect("area_event", test)
	add_child(e)
	
	e = EdgeComponent.new()
	e.create_edge(EdgeComponent.EDGE_SIDE.LEFT)
	e.connect("area_event", test)
	add_child(e)
	
	e = EdgeComponent.new()
	e.create_edge(EdgeComponent.EDGE_SIDE.RIGHT)
	e.connect("area_event", test)
	add_child(e)
	
	e = EdgeComponent.new()
	e.create_edge(EdgeComponent.EDGE_SIDE.BOTTOM)
	e.connect("area_event", test)
	add_child(e)
	
	draggableComponent = $DraggableComponent
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):		
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
	if Input.is_action_just_pressed("click") && draggableComponent.is_hovered:
		draggableComponent.being_dragged = true
		clicked_at = get_global_mouse_position()
		vector_to_center = clicked_at - position
		start_drag.emit(clicked_at)
	if Input.is_action_just_released("click"): # && draggableComponent.is_hovered:
		draggableComponent.being_dragged = false
		end_drag.emit()

func test():
	start_drag.emit()
	print("sugoi")
	pass

func _on_edge_component_area_entered(area):
	print("area entered")
	pass # Replace with function body.


func highlight(toggle : bool):
	#$Sprite2D.disable = toggle
	print("highlight or something")
	pass
	


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
		EdgeComponent.EDGE_SIDE.TOP:
			$TopEdgeComponent.can_connect = set_value
		EdgeComponent.EDGE_SIDE.RIGHT:
			$RightEdgeComponent.can_connect = set_value
		EdgeComponent.EDGE_SIDE.BOTTOM:
			$BottomEdgeComponent.can_connect = set_value

func turn_off_edges():
	$LeftEdgeComponent/CollisionShape2D.disabled = true
	$TopEdgeComponent/CollisionShape2D.disabled = true
	$RightEdgeComponent/CollisionShape2D.disabled = true
	$BottomEdgeComponent/CollisionShape2D.disabled = true


# TODO: make these much more clean holy moly
func _on_left_edge_component_area_entered(area):

	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.LEFT)	


func _on_top_edge_component_area_entered(area):

	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.TOP)	



func _on_right_edge_component_area_entered(area):
	return
	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
		
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.RIGHT)	


func _on_bottom_edge_component_area_entered(area):
	return
	if area.get_collision_layer_value(3) and\
		#draggableComponent.being_dragged and\
		area.can_connect == true and\
		area.edge_side == EdgeComponent.EDGE_SIDE.TOP:
			
		edge_entered(self, area.get_parent(), EdgeComponent.EDGE_SIDE.BOTTOM)


func edge_entered(source_tile, connecting_tile, edge_connected_on):
	connect_two_tiles.emit(source_tile, connecting_tile, edge_connected_on)


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
