extends Node2D

signal player_entered_exit()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hitbox_area_entered(area):
	print("heyo")
	if get_parent().does_group_have_player():
		player_entered_exit.emit()
		pass # Replace with function body.
