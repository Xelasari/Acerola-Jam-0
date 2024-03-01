extends Area2D

var size_of_field : Vector2
var size_of_tile : int
var interior_scale_of_field : Vector2

var sprite2D : Sprite2D

var counter = 0
var times = 1

@onready var polygon : PackedVector2Array = $CollisionPolygon2D.polygon

# Called when the node enters the scene tree for the first time.
func _ready():
	size_of_field = Vector2(2, 2)
	size_of_tile = 32
	interior_scale_of_field = Vector2(0.25, 0.25)
	
	position = Vector2(32, 32)
	
	set_field_scale(size_of_field)
	
	sprite2D = $Sprite2D
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	


func set_field_scale(scale : Vector2):
	
	$CollisionPolygon2D.polygon = [Vector2(0, 0),\
									Vector2(0, size_of_tile * scale.y),\
									Vector2(size_of_tile * scale.x, size_of_tile * scale.y),\
									Vector2(size_of_tile * scale.x, 0)]
									
	$Sprite2D.scale = 0.25 * scale
	pass


func _on_area_entered(area):
	print("hello")
	area.set_player_speed_scale(interior_scale_of_field)
	pass # Replace with function body.


func _on_area_exited(area):
	print("goodbye")
	area.set_player_speed_scale(Vector2(1, 1))
	pass # Replace with function body.
