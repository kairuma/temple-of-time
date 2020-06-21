extends "res://scene/entity/Entity.gd"

signal tick

func _ready() -> void:
	set_process(true)

func _process(delta: float) -> void:
	check_move()

func check_move() -> void:
	if !$Tween.is_active():
		if Input.is_action_pressed("up"):
			if move_up():
				emit_signal("tick")
		elif Input.is_action_pressed("down"):
			if move_down():
				emit_signal("tick")
		elif Input.is_action_pressed("left"):
			if move_left():
				emit_signal("tick")
		elif Input.is_action_pressed("right"):
			if move_right():
				emit_signal("tick")
