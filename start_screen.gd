extends Control

signal start_game()
signal level_select_menu()
signal credits_page()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _on_start_button_pressed():
	start_game.emit()


func _on_level_select_button_pressed():
	level_select_menu.emit()


func _on_credits_button_pressed():
	credits_page.emit()
