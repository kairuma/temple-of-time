extends Node2D
class_name Entity

enum EntityID {PLAYER, SPRITE, STAIRS_UP, STAIRS_DOWN, BAKU}

const CELL_SIZE: float = 32.0
const TURN_SPEED: float = 0.25

var map_x: int = 0 setget set_map_x, get_map_x
var map_y: int = 0 setget set_map_y, get_map_y
export(int, -5, 5) var strength: int = 0
export(int, -5, 5) var agility: int = 0
export(int, 1, 20) var level: int = 1
export(int, -5, 5) var vitality: int = 0 setget set_vitality
export(bool) var npc: bool = false setget ,is_npc
export(bool) var player: bool = false setget ,is_player
export(EntityID) var id: int = EntityID.SPRITE setget ,get_id
var max_hp: int = 1 setget set_max_hp
var hp: int = 1 setget set_hp
var melee_attack: int = 0
var armor_defense: int = 0

export(NodePath) var map_path: NodePath
onready var map: Node2D = get_node(map_path) setget set_map

func get_id() -> int:
	return id

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

func set_vitality(v: int) -> void:
	vitality = v
	set_max_hp((vitality + 5) * 5 + 10 * level / 3)

func set_max_hp(h: int) -> void:
	var old_max: int = max_hp
	max_hp = h
	hp = hp * max_hp / old_max

func set_hp(h: int) -> void:
	hp = h
	if hp <= 0:
		die()

func is_at(x: int, y: int) -> bool:
	return map_x == x and map_y == y

func is_npc() -> bool:
	return npc

func is_player() -> bool:
	return player

func take_damage(damage: int, source: Entity) -> void:
	set_hp(hp - damage)

func die() -> void:
	queue_free()

func get_weapon_damage() -> int:
	if melee_attack == 0:
		return 1
	return (randi() % melee_attack + 1) * 5

func get_defense() -> int:
	return 10 + agility + armor_defense

func attack(entity: Entity) -> void:
	$AnimationPlayer.play("attack")
	var to_hit: int = randi() % 20 + 1 + strength
	var damage_mult: float = (21.0 - (entity.get_defense() - to_hit)) / 20.0
	var damage: int = get_weapon_damage() + strength * 5
	damage *= damage_mult
	if damage <= 0:
		damage = 1
	entity.take_damage(damage, self)

func interact(entity: Entity) -> void:
	pass

func move_up() -> bool:
	if map.is_ground(map_x, map_y - 1):
		var entity: Entity = map.get_entity_at(map_x, map_y - 1)
		if entity == null or (!entity.is_npc() and !entity.is_player()):
			set_map_y(map_y - 1)
			if entity != null:
				entity.interact(self)
		else:
			attack(entity)
		return true
	return false

func move_down() -> bool:
	if map.is_ground(map_x, map_y + 1):
		var entity: Entity = map.get_entity_at(map_x, map_y + 1)
		if entity == null or (!entity.is_npc() and !entity.is_player()):
			set_map_y(map_y + 1)
			if entity != null:
				entity.interact(self)
		else:
			attack(entity)
		return true
	return false

func move_left() -> bool:
	if map.is_ground(map_x - 1, map_y):
		var entity: Entity = map.get_entity_at(map_x - 1, map_y)
		if entity == null or (!entity.is_npc() and !entity.is_player()):
			set_map_x(map_x - 1)
			if entity != null:
				entity.interact(self)
		else:
			attack(entity)
		return true
	return false

func move_right() -> bool:
	if map.is_ground(map_x + 1, map_y):
		var entity: Entity = map.get_entity_at(map_x + 1, map_y)
		if entity == null or (!entity.is_npc() and !entity.is_player()):
			set_map_x(map_x + 1)
			if entity != null:
				entity.interact(self)
		else:
			attack(entity)
		return true
	return false

func update() -> void:
	return
