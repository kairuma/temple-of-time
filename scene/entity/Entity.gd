extends Node2D
class_name Entity

const CELL_SIZE: float = 48.0
const TURN_SPEED: float = 0.5

export(int, 0, 96) var map_x: int = 0 setget set_map_x, get_map_x
export(int, 0, 96) var map_y: int = 0 setget set_map_y, get_map_y
export(int, 1, 100) var hp: int = 1
export(int, -5, 5) var strength: int = 0
export(int, -5, 5) var agility: int = 0

export(NodePath) var map_path: NodePath
onready var map: Node2D = get_node(map_path) setget set_map

func set_map_x(new_x: int) -> void:
	map_x = new_x
	$Tween.interpolate_property(self, "position", get_position(), Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE), TURN_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func get_map_x() -> int:
	return map_x

func set_map_y(new_y: int) -> void:
	map_y = new_y
	$Tween.interpolate_property(self, "position", get_position(), Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE), TURN_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func get_map_y() -> int:
	return map_y

func set_map(m: Node2D) -> void:
	map = m

func take_damage(damage: int) -> void:
	hp -= damage

func get_weapon_damage() -> int:
	return randi() % weapon_attack

func get_ac() -> int:
	return 10 + agility + armor_defense

func attack(entity: Entity) -> void:
	var attack_value: int = randi() % 20 + 1 + strength
	if attack_value > entity.get_ac():
		entity.take_damage(get_weapon_damage() + strength)

func move_up() -> bool:
	if map.is_ground(map_x, map_y - 1):
		var entity: Entity = map.get_entity_at(map_x, map_y - 1)
		if entity == null:
			set_map_y(map_y - 1)
		else:
			attack(entity)
		return true
	return false

func move_down() -> bool:
	if map.is_ground(map_x, map_y + 1):
		var entity: Entity = map.get_entity_at(map_x, map_y + 1)
		if entity == null:
			set_map_y(map_y + 1)
		else:
			attack(entity)
		return true
	return false

func move_left() -> bool:
	if map.is_ground(map_x - 1, map_y):
		var entity: Entity = map.get_entity_at(map_x - 1, map_y)
		if entity == null:
			set_map_x(map_x - 1)
		else:
			attack(entity)
		return true
	return false

func move_right() -> bool:
	if map.is_ground(map_x + 1, map_y):
		var entity: Entity = map.get_entity_at(map_x + 1, map_y)
		if entity == null:
			set_map_x(map_x + 1)
		else:
			attack(entity)
		return true
	return false

func update() -> void:
	return
