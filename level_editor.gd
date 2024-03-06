@tool
extends Node


@export var level_name : String
@export var level_number : int

var map_size : Vector2i = Vector2i(0, 0)

var map_data : Array[Array]

var spawn : Vector2i

var exit : Vector2i

var cuts_allowed : int


#
func _run():
	print("test?")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Engine.is_editor_hint():
		print("is editor?")
	if Input.is_action_just_pressed("space"):
		#write_map_to_json()
		var mapLayer : TileMap = $MapLayer
		print(mapLayer.get_used_rect())
		
		
		
		
func write_map_to_json(new_value: bool) -> void:
	pass
	
func read_map_from_json():
	pass

