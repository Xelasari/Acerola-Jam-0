extends Node2D

var speed : Vector2
var speed_scale : Vector2

var tiles_on_top_of : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = Vector2(2.0, 2.0)
	speed_scale = Vector2(1.0, 1.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_vector = Input.get_vector("left", "right", "up", "down")

	position += (speed * speed_scale) * input_vector
	
	#if tiles_on_top_of.is_empty():
	#	print("Technically dead")
	#else:
	#	print("Safe")


func _on_hitbox_set_speed_scale(scale):
	speed_scale = scale


func _on_ground_detector_area_entered(area):
	tiles_on_top_of.append(area)


func _on_ground_detector_area_exited(area):
	tiles_on_top_of.erase(area)
