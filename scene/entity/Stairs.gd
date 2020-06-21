extends "res://scene/entity/Entity.gd"

signal move_up
signal move_down

var going_down: bool = true setget set_going_down
var down_texture: Texture = preload("res://img/entity/stairs_down.png")
var up_texture: Texture = preload("res://img/entity/stairs_up.png")

func set_going_down(b: bool) -> void:
	going_down = b
	if going_down:
		id = EntityID.STAIRS_DOWN
		$Sprite.set_texture(down_texture)
	else:
		id = EntityID.STAIRS_UP
		$Sprite.set_texture(up_texture)

func interact(entity: Entity) -> void:
	if going_down:
		emit_signal("move_down")
	else:
		emit_signal("move_up")
