extends "res://scene/entity/Entity.gd"

func _ready() -> void:
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("up"):
		move_up()
	elif event.is_action_pressed("down"):
		move_down()
	elif event.is_action_pressed("left"):
		move_left()
	elif event.is_action_pressed("right"):
		move_right()
