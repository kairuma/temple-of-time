extends Sprite
class_name Tile

var map_x: int = -1 setget ,get_map_x
var map_y: int = -1 setget ,get_map_y
var alive: bool = true

func is_alive() -> bool:
	return alive

func get_map_x() -> int:
	return map_x

func get_map_y() -> int:
	return map_y

func set_map_pos(x: int, y: int) -> void:
	map_x = x
	map_y = y
	var start_pos: Vector2 = Vector2(map_x * Entity.CELL_SIZE, map_y * Entity.CELL_SIZE)
	$Tween.interpolate_property(self, "position", start_pos - Vector2(0.0, 128.0), start_pos, 0.25, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.interpolate_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), Color(1.0, 1.0, 1.0, 1.0), 0.25, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()
	show()

func remove() -> void:
	alive = false
	var start_pos: Vector2 = Vector2(map_x * Entity.CELL_SIZE, map_y * Entity.CELL_SIZE)
	$Tween.interpolate_property(self, "position", start_pos, start_pos + Vector2(0.0, 128.0), 0.25, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(self, "scale", Vector2(1.0, 1.0), Vector2(0.5, 0.5), 0.25, Tween.TRANS_EXPO, Tween.EASE_IN)
	$Tween.interpolate_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), Color(1.0, 1.0, 1.0, 0.0), 0.25, Tween.TRANS_EXPO, Tween.EASE_OUT)
	$Tween.start()

func check_free() -> void:
	if !alive:
		queue_free()
