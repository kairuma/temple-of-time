extends MarginContainer

func resume_game() -> void:
	get_tree().set_pause(false)
	hide()

func show_options() -> void:
	get_tree().set_pause(true)
	$OptionsMenu.show()
