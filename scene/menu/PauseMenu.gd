extends MarginContainer

func resume_game() -> void:
	get_tree().set_pause(false)
	hide()

func show_options() -> void:
	$OptionsMenu.show()

func save_and_quit() -> void:
	Global.save_game()
	get_tree().set_pause(false)
	get_tree().change_scene("res://scene/state/MainMenu.tscn")
