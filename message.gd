extends Node2D


var being_read : bool = false
var current_alpha : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if being_read and current_alpha < 1.0: current_alpha += 0.05
	elif !being_read and current_alpha > 0.0: current_alpha -= 0.05
	$MessageText.modulate = Color(1, 1, 1, current_alpha)
	
func set_message_text(text : String):
	$MessageText.text = "[center]" + text + "[/center]"



func _on_hitbox_area_entered(area):
	being_read = true


func _on_hitbox_area_exited(area):
	being_read = false
