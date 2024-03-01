extends Node2D

var speed : Vector2
var speed_scale : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	speed = Vector2(4.0, 4.0)
	speed_scale = Vector2(1.0, 1.0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var input_vector = Input.get_vector("left", "right", "up", "down")

	position += (speed * speed_scale) * input_vector


func _on_hitbox_set_speed_scale(scale):
	speed_scale = scale
