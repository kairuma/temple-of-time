extends "res://scene/entity/Entity.gd"

var target: Entity = null

func take_damage(damage: int, source: Entity) -> void:
	.take_damage(damage, source)
	target = source

func update() -> void:
	if target != null:
		#astar eventually I guess
		if map_x < target.get_map_x():
			move_right()
			print("right")
		elif map_x > target.get_map_x():
			move_left()
			print("left")
		elif map_y < target.get_map_y():
			move_down()
			print("down")
		elif map_y > target.get_map_y():
			move_up()
			print("up")
