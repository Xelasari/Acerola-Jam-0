extends Control

@export var levelSelectButtonScene : PackedScene

var test_levels_unlocked : int = 30

signal level_select_button_pressed(level_number : int)
signal return_to_main_menu()

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(test_levels_unlocked):
		var new_button = levelSelectButtonScene.instantiate()
		new_button.level_number = i + 1
		new_button.custom_minimum_size = Vector2(100, 50)
		new_button.get_node("Button").custom_minimum_size = Vector2(100, 50)
		new_button.get_node("Button").text = "Level " + str(i + 1)
		new_button.connect("level_select_button_pressed", _on_level_select_button_pressed)
		$GridContainer.add_child(new_button)
		
		#var test : Button = Button.new()
		#test.custom_minimum_size = Vector2(100, 50)
		#test.text = "Level " + str(i + 1)
		#test.connect("pressed", _on_button_press)
		#$GridContainer.add_child(test)
		#pass
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_level_select_button_pressed(level_number : int):
	level_select_button_pressed.emit(level_number)


func _on_return_to_title_screen_button_pressed():
	return_to_main_menu.emit()

func check_if_levels_unlocked(levels_cleared):
	for c in $GridContainer.get_children():
		print(c.level_number)
		if c.level_number <= levels_cleared:
			c.visible = true
		else:
			c.visible = false
