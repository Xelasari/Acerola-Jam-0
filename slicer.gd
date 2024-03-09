extends Node2D

var x_length = 2000
var y_length = 2000

var shapeCast2D : ShapeCast2D
var collisionShape2D : CollisionShape2D
var cutMarker : Sprite2D
var knifeSprite : Sprite2D


var currently_touching_edges : Array[EdgeComponent] = []


enum ORIENTATION {VERTICAL, HORIZONTAL}
var orientation : ORIENTATION = ORIENTATION.VERTICAL

signal cut_at(tile_group, direction_of_cut, location_of_cut)
signal turn_on_highlight(tile, direction_of_cut)
signal turn_off_highlight(tile, direction_of_cut)

# Called when the node enters the scene tree for the first time.
func _ready():
	shapeCast2D = $ShapeCast2D
	collisionShape2D = $Area2D/CollisionShape2D
	cutMarker = $CutMarker
	knifeSprite = $KnifeSprite


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
		#print(orientation)
		
		if orientation == ORIENTATION.VERTICAL:
			collisionShape2D.rotate(deg_to_rad(90))
			knifeSprite.rotate(deg_to_rad(90))
			knifeSprite.position = Vector2(16, 14)
		if orientation == ORIENTATION.HORIZONTAL:
			collisionShape2D.rotate(deg_to_rad(-90))
			knifeSprite.rotate(deg_to_rad(-90))
			knifeSprite.position = Vector2(16, -14)
	
	for area in currently_touching_edges:
		var tile_group = area.get_parent().tiles_connected_to
		var coord_to_check : int
		if orientation == ORIENTATION.VERTICAL && area.edge_side == area.EDGE_SIDE.LEFT:
			coord_to_check = area.get_parent().local_position.x
			for t in tile_group:
				#if t.local_position.x == coord_to_check:
				#	t.get_node("ColorRight").color = Color(0, 0, 0, 1)
				if t.local_position.x == coord_to_check:
					t.get_node("ColorLeft").color = Color(0, 0, 0, 1)
		if orientation == ORIENTATION.VERTICAL && area.edge_side == area.EDGE_SIDE.RIGHT:
			coord_to_check = area.get_parent().local_position.x
			for t in tile_group:
				if t.local_position.x == coord_to_check:
					t.get_node("ColorRight").color = Color(0, 0, 0, 1)
			
		if orientation == ORIENTATION.HORIZONTAL && area.edge_side == area.EDGE_SIDE.TOP:
			coord_to_check = area.get_parent().local_position.y
			for t in tile_group:
				if t.local_position.y == coord_to_check:
					t.get_node("ColorTop").color = Color(0, 0, 0, 1)
		if orientation == ORIENTATION.HORIZONTAL && area.edge_side == area.EDGE_SIDE.BOTTOM:
			coord_to_check = area.get_parent().local_position.y
			for t in tile_group:
				if t.local_position.y == coord_to_check:
					t.get_node("ColorBottom").color = Color(0, 0, 0, 1)

# On rotate, somehow recheck these?
# Or maybe, move this to _process and just check currently_touching_edges
func _on_area_2d_area_entered(area):
	#turn_on_highlight.emit(area.get_parent(), orientation)
	#if orientation == ORIENTATION.VERTICAL:
	#	area.get_parent().turn_on_highlight_line(area, "vertical")
	#if orientation == ORIENTATION.HORIZONTAL:
	#	area.get_parent().turn_on_highlight_line(area, "horizontal")
	currently_touching_edges.append(area)


func _on_area_2d_area_exited(area):
	#if orientation == ORIENTATION.VERTICAL:
	#	area.get_parent().turn_off_highlight_line(area, "vertical")
	#if orientation == ORIENTATION.HORIZONTAL:
	#	area.get_parent().turn_off_highlight_line(area, "horizontal")
	currently_touching_edges.erase(area)

