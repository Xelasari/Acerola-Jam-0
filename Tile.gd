extends Node2D

var draggableComponent : DraggableComponent


var clicked_at : Vector2
var vector_to_center : Vector2

signal start_drag()
signal end_drag()
signal attempt_connection(area)

# Called when the node enters the scene tree for the first time.
func _ready():
	draggableComponent = $DraggableComponent
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
	


# TODO: make these much more clean holy moly
func _on_left_edge_component_area_entered(area):
	if draggableComponent.being_dragged:
		print("left")
		attempt_connection.emit(area.get_parent().get_parent())
	pass # Replace with function body.


func _on_top_edge_component_area_entered(area):
	if draggableComponent.being_dragged:
		print("top")
		attempt_connection.emit(area.get_parent().get_parent())
	pass # Replace with function body.


func _on_right_edge_component_area_entered(area):
	if draggableComponent.being_dragged:
		print("right")
		attempt_connection.emit(area.get_parent().get_parent())
	pass # Replace with function body.


func _on_bottom_edge_component_area_entered(area):
	if draggableComponent.being_dragged:
		print("bottom")
		attempt_connection.emit(area.get_parent().get_parent())
	pass # Replace with function body.
