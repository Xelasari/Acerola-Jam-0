extends Area2D


class_name EdgeComponent


enum EDGE_SIDE {TOP, LEFT, RIGHT, BOTTOM}
@export var edge_side : EDGE_SIDE

#var edge_side : int

# Rectangle specs (4, 26) (26, 4) and pos of (-16, 0) (0, -16)

signal area_event()

# This component works as an edge for a tile that should snap to other edges
# top+bottom, left+right, etc.

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func create_edge(side : int):
	var new_edge : CollisionShape2D
	var new_shape = RectangleShape2D.new()
	
	#edge_side = side
	
	new_edge = CollisionShape2D.new()
	
	match side:
		EDGE_SIDE.TOP:
			new_shape.set_size(Vector2(26, 4))
			new_edge.position = Vector2(0, -16)
		EDGE_SIDE.LEFT:
			new_shape.set_size(Vector2(4, 26))
			new_edge.position = Vector2(-16, 0)
		EDGE_SIDE.RIGHT:
			new_shape.set_size(Vector2(4, 26))
			new_edge.position = Vector2(16, 0)
		EDGE_SIDE.BOTTOM:
			new_shape.set_size(Vector2(26, 4))
			new_edge.position = Vector2(0, 16)
	
	new_edge.set_shape(new_shape)
	
	add_child(new_edge)
	
	


func _on_area_entered(area):
	area_event.emit()
	print("area entered")
	pass # Replace with function body.
