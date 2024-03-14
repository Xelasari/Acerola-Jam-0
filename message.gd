extends Node2D


var being_read : bool = false
var current_alpha : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$MessageText.modulate = Color(1, 1, 1, 0)
	$Panel.modulate = Color(1, 1, 1, 0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.d
func _process(delta):
	if being_read and current_alpha < 1.0: current_alpha += 0.05
	elif !being_read and current_alpha > 0.0: current_alpha -= 0.05
	$Panel.size = $MessageText.size
	$Panel.position = $MessageText.position
	$MessageText.modulate = Color(1, 1, 1, current_alpha)
	$Panel.modulate = Color(1, 1, 1, current_alpha)
	
	if get_parent().position.y > 360:
		$MessageText.set_anchors_preset(Control.PRESET_CENTER_TOP)
		$Panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	else:
		$MessageText.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
		$Panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	
func set_message_text(text : String):
	$MessageText.text = "[center]" + text + "[/center]"
	var test_size_var = $MessageText.size
	print(test_size_var)
	#$Panel.size = $MessageText.size



func _on_hitbox_area_entered(area):
	being_read = true


func _on_hitbox_area_exited(area):
	being_read = false
