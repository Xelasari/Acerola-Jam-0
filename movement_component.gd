extends Node

class_name MovementComponent


var position : Vector2
var velocity : Vector2

signal update_position(pos : Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	position = get_parent().position
	print(position)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	return
	position += velocity * delta
	update_position.emit(position)
