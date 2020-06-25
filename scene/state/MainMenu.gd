extends MarginContainer

onready var continue_button: Button = $HBoxContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	if File.new().file_exists("user://player.sav"):
		continue_button.show()

func new_game() -> void:
	Global.delete_save()
	Global.set_new_game(true)
	get_tree().change_scene("res://scene/state/Gameplay.tscn")

func load_game() -> void:
	Global.set_new_game(false)
	get_tree().change_scene("res://scene/state/Gameplay.tscn")

func show_options() -> void:
	$OptionsMenu.show()

func show_about() -> void:
	$AboutPopup.show()

func hide_about() -> void:
	$AboutPopup.hide()
