extends "res://scene/entity/Entity.gd"

signal tick

onready var hp_label: Label = $CanvasLayer/MarginContainer/VBoxContainer/HpLabel
onready var hp_bar: Label = $CanvasLayer/MarginContainer/VBoxContainer/HpBar

func _ready() -> void:
	set_process(true)
	set_max_hp(max_hp)
	set_hp(hp)

func _process(delta: float) -> void:
	check_move()

func can_move() -> bool:
	return !$Tween.is_active() and !$AnimationPlayer.is_playing()

func check_move() -> void:
	if can_move():
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
				emit_signal("tick")\

func set_max_hp(h: int) -> void:
	.set_max_hp(h)
	if hp_label != null:
		hp_label.set_text("HP: %d / %d" % [hp, max_hp])
	if hp_bar != null:
		hp_bar.set_max(max_hp)

func set_hp(h: int) -> void:
	.set_hp(h)
	print(hp_label)
	if hp_label != null:
		hp_label.set_text("HP: %d / %d" % [hp, max_hp])
	if hp_bar != null:
		hp_bar.set_value(hp)

func die() -> void:
	get_tree().change_scene("res://scene/state/GameOver.tscn")
