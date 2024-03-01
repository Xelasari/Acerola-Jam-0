extends Node2D

var draggableComponent : DraggableComponent


var clicked_at : Vector2
var vector_to_center : Vector2

var local_position : Vector2i
var parent_tile_group : Node

signal start_drag()
signal end_drag()
signal attempt_connection(area, triggered_side)

# Called when the node enters the scene tree for the first time.
func _ready():
	draggableComponent = $DraggableComponent
	parent_tile_group = get_parent()
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
	#if draggableComponent.being_dragged:
	#	position = get_global_mouse_position() - vector_to_center
	
	
	pass


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
	if Input.is_action_just_released("click") && draggableComponent.is_hovered:
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
	


func set_edge_collision(side : EdgeComponent.EDGE_SIDE, set_value : bool):
	print("set " + str(side) + " to " + str(set_value))
	match side:
		EdgeComponent.EDGE_SIDE.LEFT:
			$LeftEdgeComponent/CollisionShape2D.disabled = set_value
		EdgeComponent.EDGE_SIDE.TOP:
			$TopEdgeComponent/CollisionShape2D.disabled = set_value
		EdgeComponent.EDGE_SIDE.RIGHT:
			$RightEdgeComponent/CollisionShape2D.disabled = set_value
		EdgeComponent.EDGE_SIDE.BOTTOM:
			$BottomEdgeComponent/CollisionShape2D.disabled = set_value

func turn_off_edges():
	$LeftEdgeComponent/CollisionShape2D.disabled = true
	$TopEdgeComponent/CollisionShape2D.disabled = true
	$RightEdgeComponent/CollisionShape2D.disabled = true
	$BottomEdgeComponent/CollisionShape2D.disabled = true


# TODO: make these much more clean holy moly
func _on_left_edge_component_area_entered(area):
	print("left")
	if area.get_collision_layer_value(3) and\
		draggableComponent.being_dragged and\
		area.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
			
		attempt_connection.emit(area.get_parent(), EdgeComponent.EDGE_SIDE.LEFT)
	pass # Replace with function body.


func _on_top_edge_component_area_entered(area):
	print("top")
	if area.get_collision_layer_value(3) and\
		draggableComponent.being_dragged and\
		area.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
			
		attempt_connection.emit(area.get_parent(), EdgeComponent.EDGE_SIDE.TOP)
	pass # Replace with function body.


func _on_right_edge_component_area_entered(area):
	print("right")
	if area.get_collision_layer_value(3) and\
		draggableComponent.being_dragged and\
		area.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
			
		attempt_connection.emit(area.get_parent(), EdgeComponent.EDGE_SIDE.RIGHT)
	pass # Replace with function body.


func _on_bottom_edge_component_area_entered(area):
	print("bottom")
	if area.get_collision_layer_value(3) and\
		draggableComponent.being_dragged and\
		area.edge_side == EdgeComponent.EDGE_SIDE.TOP:
			
		attempt_connection.emit(area.get_parent(), EdgeComponent.EDGE_SIDE.BOTTOM)
	pass # Replace with function body.
