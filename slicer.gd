extends Node2D

var x_length = 2000
var y_length = 2000

var shapeCast2D : ShapeCast2D
var collisionShape2D : CollisionShape2D
var cutMarker : Sprite2D


var currently_touching_edges : Array[EdgeComponent] = []


enum ORIENTATION {VERTICAL, HORIZONTAL}
var orientation : ORIENTATION = ORIENTATION.VERTICAL

signal cut_at(tile_group, direction_of_cut, location_of_cut)

# Called when the node enters the scene tree for the first time.
func _ready():
	shapeCast2D = $ShapeCast2D
	collisionShape2D = $Area2D/CollisionShape2D
	cutMarker = $CutMarker


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = get_global_mouse_position()
	
	#print("areas in array: " + str(currently_touching_edges.size()))
	
	if Input.is_action_just_pressed("space"):
		for e in currently_touching_edges:
			if orientation == ORIENTATION.VERTICAL:
				if e.edge_side == EdgeComponent.EDGE_SIDE.LEFT:
					cut_at.emit(e.get_parent().tiles_connected_to, "vertical", e.get_parent().local_position.x - 1)
					break
				#if e.edge_side == EdgeComponent.EDGE_SIDE.RIGHT:
				#	cut_at.emit(e.get_parent().tiles_connected_to, "vertical", e.get_parent().local_position.x - 1)
				#	break
			if orientation == ORIENTATION.HORIZONTAL:
				if e.edge_side == EdgeComponent.EDGE_SIDE.TOP:
					cut_at.emit(e.get_parent().tiles_connected_to, "horizontal", e.get_parent().local_position.y - 1)
					break
				#if e.edge_side == EdgeComponent.EDGE_SIDE.BOTTOM:
				#	cut_at.emit(e.get_parent().tiles_connected_to, "horizontal", e.get_parent().local_position.y - 1)
				#	break
	if Input.is_action_just_pressed("right click"):
		orientation = (orientation + 1) % 2
		print(orientation)
		
		if orientation == ORIENTATION.VERTICAL:
			collisionShape2D.rotate(deg_to_rad(-90))
			cutMarker.rotate(deg_to_rad(-90))
			#collisionShape2D.shape.set("x", 4)
			#collisionShape2D.shape.set("y", 16)
			#$Area2D/CollisionShape2D.shape.x = 4
			#$Area2D/CollisionShape2D.shape.x = 16
		if orientation == ORIENTATION.HORIZONTAL:
			collisionShape2D.rotate(deg_to_rad(90))
			cutMarker.rotate(deg_to_rad(90))
			#collisionShape2D.shape.set("x", 16)
			#collisionShape2D.shape.set("y", 4)
			#$Area2D/CollisionShape2D.shape.x = 16
			#$Area2D/CollisionShape2D.shape.x = 4
	


func _on_area_2d_area_entered(area):
	currently_touching_edges.append(area)


func _on_area_2d_area_exited(area):
	currently_touching_edges.erase(area)

