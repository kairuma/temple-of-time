extends Sprite

const CELL_SIZE: float = 48.0
const TURN_SPEED: float = 0.5

export(int, -1000000000, 1000000000) var map_x: int = 0 setget set_map_x
export(int, -1000000000, 1000000000) var map_y: int = 0 setget set_map_y

func set_map_x(new_x: int) -> void:
	map_x = new_x
	$Tween.interpolate_property(self, "position", get_position(), Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE), TURN_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func set_map_y(new_y: int) -> void:
	map_y = new_y
	$Tween.interpolate_property(self, "position", get_position(), Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE), TURN_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func move_up() -> void:
	set_map_y(map_y - 1)

func move_down() -> void:
	set_map_y(map_y + 1)

func move_left() -> void:
	set_map_x(map_x - 1)

func move_right() -> void:
	set_map_x(map_x + 1)

func update() -> void:
	return
