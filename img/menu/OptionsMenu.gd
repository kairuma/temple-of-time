extends CenterContainer

onready var hour_24_button: Button = $VBoxContainer/Hour24Button

func _ready() -> void:
	if Global.display_hour_24():
		hour_24_button.set_text("Display 24-Hour Clock")
		hour_24_button.set_pressed(true)
	else:
		hour_24_button.set_text("Display 12-Hour Clock")
		hour_24_button.set_pressed(false)

func toggle_hour_24(button_pressed: bool) -> void:
	Global.set_hour_24(button_pressed)
	if Global.display_hour_24():
		hour_24_button.set_text("Display 24-Hour Clock")
	else:
		hour_24_button.set_text("Display 12-Hour Clock")

func hide_self() -> void:
	get_tree().set_pause(false)
	hide()
