extends Control

var level_number : int

signal level_select_button_pressed(level_number : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	print("Load level " + str(level_number))
	level_select_button_pressed.emit(level_number)
