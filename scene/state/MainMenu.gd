extends MarginContainer

func new_game() -> void:
	get_tree().change_scene("res://scene/state/Gameplay.tscn")

func load_game() -> void:
	pass

func show_options() -> void:
	get_tree().set_pause(true)
	$OptionsMenu.show()

func show_about() -> void:
	$AboutPopup.show()

func hide_about() -> void:
	$AboutPopup.hide()
