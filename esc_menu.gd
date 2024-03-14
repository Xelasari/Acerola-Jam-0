extends Panel


signal return_to_title()


func _on_return_to_title_button_pressed():
	return_to_title.emit()


func _on_quit_to_desktop_button_pressed():
	get_tree().quit()
