extends Area2D


signal set_speed_scale(scale : Vector2)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_player_speed_scale(scale : Vector2):
	set_speed_scale.emit(scale)
