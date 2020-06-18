extends Sprite

const CELL_SIZE: float = 32.0

export(int, -1000000000, 1000000000) var map_x: int = 0
export(int, -1000000000, 1000000000) var map_y: int = 0

func move_up() -> void:
	map_y -= 1
	set_position(Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE))

func move_down() -> void:
	map_y += 1
	set_position(Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE))

func move_left() -> void:
	map_x -= 1
	set_position(Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE))

func move_right() -> void:
	map_x += 1
	set_position(Vector2(map_x * CELL_SIZE, map_y * CELL_SIZE))
