extends Control


signal return_to_title()

var cheat_string : String


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if visible:
		if Input.is_action_just_pressed("up"):
			if cheat_string == "up":
				cheat_string += "up"
			else:
				cheat_string = "up"
			pass
		if Input.is_action_just_pressed("down"):
			if cheat_string == "upup":
				cheat_string += "down"
			elif cheat_string == "upupdown":
				cheat_string += "down"
			else:
				cheat_string = "down"
			
		if Input.is_action_just_pressed("right"):
			if cheat_string == "upupdowndownleft":
				cheat_string += "right"
			elif cheat_string == "upupdowndownleftrightleft":
				$UnlockSound.play()
				var file = FileAccess.open("res://save_data.txt", FileAccess.WRITE)
				get_parent().levels_cleared = 30
				file.store_string(str(30))
			else:
				cheat_string = "right"
		if Input.is_action_just_pressed("left"):
			if cheat_string == "upupdowndown":
				cheat_string += "left"
			elif cheat_string == "upupdowndownleftright":
				cheat_string += "left"
			else:
				cheat_string = "left"
			pass
		#print("sneaky cheats")
	pass


func _on_return_to_title_button_pressed():
	return_to_title.emit()
