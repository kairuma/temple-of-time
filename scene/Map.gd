extends Node2D

const ROOM_ITERATIONS: int = 1024
const MONTH_NAME: Dictionary = {
	1: "January", 2: "February", 3: "March", 4: "April", 
	5: "May", 6: "June", 7: "July", 8: "August", 
	9: "September", 10: "October", 11: "November", 12: "December"
}
const MONTH_LENGTH: Dictionary = {
	1: 31, 2: 28, 3: 31, 4: 30, 
	5: 31, 6: 30, 7: 31, 8: 31, 
	9: 30, 10: 31, 11: 30, 12: 31
}

var stairs_class: Resource = preload("res://scene/entity/Stairs.tscn")
var sprite_class: Resource = preload("res://scene/entity/npc/Sprite.tscn")

var floor_num: int = 0 setget set_floor_num
var width: int = 15
var height: int = 15
var second: int = 0
var minute: int = 0
var hour: int = 0
var day: int = 1
var month: int = 1
var year: int = 2020
var seeds: PoolIntArray = []
var map_seed: int = 1597463007
var saved_entities: Array = []

func _ready() -> void:
	$Player.connect("tick", self, "update_entities")
	for i in 16:
		saved_entities.append([])
	gen_map_seeds()
	gen_map(true)
	set_start_time()

func gen_map_seeds() -> void:
	randomize()
	map_seed = ((randi() << 31) + (randi() % 0x7FFFFFFF))
	for i in 15:
		seeds.append(random_int())

func random_int() -> int:
	var result: int = (1103515245 * map_seed + 12345) / 65536 % 2048
	result = (result * 1103515245 + 12345) << 10
	result ^= result / 65536 % 1024
	result = (result * 1103515245 + 12345) << 10
	result ^= result / 65536 % 1024
	map_seed = result
	return int(abs(result))

func gen_home(going_down: bool) -> void:
	for y in height:
		for x in width:
			$TileMap.set_cell(x, y, 0)
	if going_down:
		$Player.set_map_x(7)
		$Player.set_map_y(7)
	else:
		$Player.set_map_x(7)
		$Player.set_map_y(0)
	var stairs: Entity = stairs_class.instance()
	stairs.set_going_down(true)
	$Entities.add_child(stairs)
	stairs.connect("move_down", self, "descend")
	stairs.set_map(self)
	stairs.set_map_x(7)
	stairs.set_map_y(0)

func gen_map(going_down: bool) -> void:
	if floor_num == 0:
		gen_home(going_down)
		return
	map_seed = seeds[floor_num - 1]
	var rooms: Array = []
	for i in 4:
		var rect_w: int = 3 + (random_int() % 5) * 2
		var rect_x: int = 1 + (random_int() % ((width / 2 - rect_w - 1) / 2)) * 2
		if i % 2 == 1:
			rect_x += width / 2
		var rect_h: int = 3 + (random_int() % 5) * 2
		var rect_y: int = 1 + (random_int() % ((height / 2 - rect_h - 1) / 2)) * 2
		if i > 1:
			rect_y += height / 2
		rooms.append([rect_x, rect_y, rect_w, rect_h])
	for i in range(ROOM_ITERATIONS):
		var rect_w: int = 3 + (random_int() % 5) * 2
		var rect_x: int = 1 + (random_int() % ((width - rect_w - 1) / 2)) * 2
		var rect_h: int = 3 + (random_int() % 5) * 2
		var rect_y: int = 1 + (random_int() % ((height - rect_h - 1) / 2)) * 2
		var is_valid: bool = true
		var j: int = 0
		while is_valid and j < rooms.size():
			if rect_x - 1 < rooms[j][0] + rooms[j][2] + 1 and rect_x + rect_w + 1 > rooms[j][0] - 1 and rect_y - 1 < rooms[j][1] + rooms[j][3] + 1 and rect_y + rect_h + 1 > rooms[j][1] - 1:
				is_valid = false
			j += 1
		if is_valid:
			rooms.append([rect_x, rect_y, rect_w, rect_h])
	var i: int = 0
	while i < rooms.size():
		for y in rooms[i][3]:
			for x in rooms[i][2]:
				$TileMap.set_cell(rooms[i][0] + x, rooms[i][1] + y, 0)
		i += 1
	for h in height / 2:
		for w in width / 2:
			maze_gen(w * 2 + 1, h * 2 + 1, rooms)
	add_doors(rooms)
	var dead_ends: Array = get_dead_ends()
	while dead_ends.size() != 0:
		for d in dead_ends:
			$TileMap.set_cell(d[0], d[1], -1)
		dead_ends = get_dead_ends()
	if saved_entities[floor_num] == []:
		populate(rooms)
	else:
		load_entities(saved_entities[floor_num], going_down)

func populate(rooms: Array) -> void:
	var exit_index: int = random_int() % (rooms.size() - 1)
	var i: int = 0
	for r in rooms:
		var x: int = r[0] + r[2] / 2
		var y: int = r[1] + r[3] / 2
		if r == rooms.back():
			var stairs: Entity = stairs_class.instance()
			stairs.set_going_down(false)
			$Entities.add_child(stairs)
			stairs.connect("move_up", self, "ascend")
			stairs.set_map(self)
			stairs.set_map_x(x)
			stairs.set_map_y(y)
			$Player.set_map_x(x)
			$Player.set_map_y(y)
		elif i == exit_index:
			var stairs: Entity = stairs_class.instance()
			stairs.set_going_down(true)
			$Entities.add_child(stairs)
			stairs.connect("move_down", self, "descend")
			stairs.set_map(self)
			stairs.set_map_x(x)
			stairs.set_map_y(y)
			pass
		else:
			var e: Entity = sprite_class.instance()
			$Entities.add_child(e)
			e.set_map(self)
			e.set_map_x(x)
			e.set_map_y(y)
		i += 1

func load_entities(entities: Array, going_down: bool) -> void:
	for e in entities:
		var entity: Entity
		match e[0]:
			Entity.EntityID.SPRITE:
				entity = sprite_class.instance()
			Entity.EntityID.STAIRS_UP:
				entity = stairs_class.instance()
				entity.set_going_down(false)
				entity.connect("move_up", self, "ascend")
				if going_down:
					$Player.set_map_x(e[1])
					$Player.set_map_y(e[2])
			Entity.EntityID.STAIRS_DOWN:
				entity = stairs_class.instance()
				entity.set_going_down(true)
				entity.connect("move_down", self, "descend")
				if !going_down:
					$Player.set_map_x(e[1])
					$Player.set_map_y(e[2])
			_:
				continue
		$Entities.add_child(entity)
		entity.set_map(self)
		entity.set_map_x(e[1])
		entity.set_map_y(e[2])

func is_in_room(x: int, y: int, rooms: Array) -> bool:
	for r in rooms:
		if x >= r[0] and x <= r[0] + r[2] and y >= r[1] and y <= r[1] + r[3]:
			return true
	return false

func maze_gen(x: int, y: int, rooms: Array) -> void:
	if $TileMap.get_cell(x, y) != 0:
		$TileMap.set_cell(x, y, 0)
		var walls: Array = []
		if y - 2 >= 0 and $TileMap.get_cell(x, y - 2) != 0:
			walls.append([x, y - 2])
		if y + 2 <= height and $TileMap.get_cell(x, y + 2) != 0:
			walls.append([x, y + 2])
		if x - 2 >= 0 and $TileMap.get_cell(x - 2, y) != 0:
			walls.append([x - 2, y])
		if x + 2 <= width and $TileMap.get_cell(x + 2, y) != 0:
			walls.append([x + 2, y])
		while !walls.empty():
			var index: int = random_int() % walls.size()
			var w: Array = walls[index]
			walls.remove(index)
			$TileMap.set_cell(w[0], w[1], 0)
			var needs_wall: bool = true
			var dir: Array = [0, 1, 2, 3]
			while needs_wall and dir.size() > 0:
				var dir_index: int = random_int() % dir.size()
				match dir[dir_index]:
					0:
						if w[0] - 2 >= 0 and $TileMap.get_cell(w[0] - 2, w[1]) == 0 and !is_in_room(w[0] - 2, w[1], rooms):
							$TileMap.set_cell(w[0] - 1, w[1], 0)
							needs_wall = false
					1:
						if w[0] + 2 <= width and $TileMap.get_cell(w[0] + 2, w[1]) == 0 and !is_in_room(w[0] + 2, w[1], rooms):
							$TileMap.set_cell(w[0] + 1, w[1], 0)
							needs_wall = false
					2:
						if w[1] - 2 >= 0 and $TileMap.get_cell(w[0], w[1] - 2) == 0 and !is_in_room(w[0], w[1] - 2, rooms):
							$TileMap.set_cell(w[0], w[1] - 1, 0)
							needs_wall = false
					3:
						if w[1] + 2 <= height and $TileMap.get_cell(w[0], w[1] + 2) == 0 and !is_in_room(w[0], w[1] + 2, rooms):
							$TileMap.set_cell(w[0], w[1] + 1, 0)
							needs_wall = false
				dir.remove(dir_index)
			if !needs_wall:
				if w[1] - 2 >= 0 and $TileMap.get_cell(w[0], w[1] - 2) != 0 and !walls.has([w[0], w[1] - 2]):
					walls.append([w[0], w[1] - 2])
				if w[1] + 2 <= height and $TileMap.get_cell(w[0], w[1] + 2) != 0 and !walls.has([w[0], w[1] + 2]):
					walls.append([w[0], w[1] + 2])
				if w[0] - 2 >= 0 and $TileMap.get_cell(w[0] - 2, w[1]) != 0 and !walls.has([w[0] - 2, w[1]]):
					walls.append([w[0] - 2, w[1]])
				if w[0] + 2 <= width and $TileMap.get_cell(w[0] + 2, w[1]) != 0 and !walls.has([w[0] + 2, w[1]]):
					walls.append([w[0] + 2, w[1]])

func add_doors(rooms: Array) -> void:
	for r in rooms:
		var dirs: PoolIntArray = [0, 1, 2, 3]
		if r[0] >= width - 1:
			dirs.remove(3)
		if r[0] <= 1:
			dirs.remove(2)
		if r[1] >= height - 1:
			dirs.remove(1)
		if r[1] >= 1:
			dirs.remove(0)
		var side: int = dirs[random_int() % dirs.size()]
		if side == 0 || dirs[random_int() % dirs.size()] == 0:
			for x in r[2]:
				if $TileMap.get_cell(r[0] + (x + r[2] / 2) % r[2], r[1] - 2) == 0:
					$TileMap.set_cell(r[0] + (x + r[2] / 2) % r[2], r[1] - 1, 0)
					break
		if side == 1 || dirs[random_int() % dirs.size()] == 1:
			for x in r[2]:
				if $TileMap.get_cell(r[0] + (x + r[2] / 2) % r[2], r[1] + r[3] + 1) == 0:
					$TileMap.set_cell(r[0] + (x + r[2] / 2) % r[2], r[1] + r[3], 0)
					break
		if side == 2 || dirs[random_int() % dirs.size()] == 2:
			for y in r[3]:
				if $TileMap.get_cell(r[0] - 2, r[1] + (y + r[3] / 2) % r[3]) == 0:
					$TileMap.set_cell(r[0] - 1, r[1] + (y + r[3] / 2) % r[3], 0)
					break
		if side == 3 || dirs[random_int() % dirs.size()] == 3:
			for y in r[3]:
				if $TileMap.get_cell(r[0] + r[2] + 1, r[1] + (y + r[3] / 2) % r[3]) == 0:
					$TileMap.set_cell(r[0] + r[2], r[1] + (y + r[3] / 2) % r[3], 0)
					break

func get_dead_ends() -> Array:
	var result: Array = []
	for y in height:
		for x in width:
			if $TileMap.get_cell(x, y) == 0:
				var neighbors: int = 0
				if x - 1 >= 0 and $TileMap.get_cell(x - 1, y) == 0:
					neighbors += 1
				if x + 1 <= width and $TileMap.get_cell(x + 1, y) == 0:
					neighbors += 1
				if y - 1 >= 0 and $TileMap.get_cell(x, y - 1) == 0:
					neighbors += 1
				if y + 1 <= height and $TileMap.get_cell(x, y + 1) == 0:
					neighbors += 1
				if neighbors <= 1:
					result.append([x, y])
	return result

func update_time_hud() -> void:
	var time_str: String = ""
	var year_str: String = str(year)
	if year < 0:
		year_str = "%d BC" % -year
	if Global.display_hour_24():
		time_str = "%s %02d, %s\n%02d : %02d : %02d" % [MONTH_NAME[month], day, year_str, hour, minute, second]
	else:
		if hour == 0:
			time_str = "%s %02d, %s\n12 : %02d : %02d AM" % [MONTH_NAME[month], day, year_str, minute, second]
		elif hour < 12:
			time_str = "%s %02d, %s\n%02d : %02d : %02d AM" % [MONTH_NAME[month], day, year_str, hour, minute, second]
		elif hour == 12:
			time_str = "%s %02d, %s\n12 : %02d : %02d PM" % [MONTH_NAME[month], day, year_str, minute, second]
		else:
			time_str = "%s %02d, %s\n%02d : %02d : %02d PM" % [MONTH_NAME[month], day, year_str, hour - 12, minute, second]
	$CanvasLayer/MarginContainer/TimeLabel.set_text(time_str)

func set_start_time() -> void:
	var start_time: Dictionary = OS.get_datetime()
	second = start_time["second"]
	minute = start_time["minute"]
	hour = start_time["hour"]
	day = start_time["day"]
	month = start_time["month"]
	year = start_time["year"]
	update_time_hud()

func get_month_length(m: int, y: int) -> int:
	if m == 2 and y % 4 == 0 and (y % 100 != 0 or y % 400 == 0):
		return 29
	return MONTH_LENGTH[m]

func increment_time() -> void:
	match floor_num:
		15:
			second = randi() % 60
			minute = randi() % 60
			hour = randi() % 24
			day = randi() % 31 + 1
			month = randi() % 12 + 1
			year = ((randi() << 31) + (randi() % 0x7FFFFFFF)) % 5000000013800000000 - 13800000000
		14:
			year += 4000000000
		13:
			year += 1000000000
		12:
			year += 250000000
		11:
			year += 1000000
		10:
			year += 1000
		9:
			year += 100
		8:
			year += 10
		7:
			year += 1
		6:
			month += 1
		5:
			day += 7
		4:
			day += 1
		3:
			hour += 1
		2:
			minute += 1
		_:
			second += 1
	if second >= 60:
		minute += second / 60
		second = second % 60
	if minute >= 60:
		hour += minute / 60
		minute = minute % 60
	if hour >= 24:
		day += hour / 24
		hour = hour % 24
	while day > get_month_length((month - 1) % 12 + 1, year):
		day -= get_month_length((month - 1) % 12 + 1, year)
		month += 1
		if month > 12:
			month -= 12
			year += 1
	while month > 12:
		month -= 12
		year += 1
		if day > get_month_length((month - 1) % 12 + 1, year):
			day -= get_month_length((month - 1) % 12 + 1, year)
	if year > 5000000000000000000:
		year = year - 5000000013800000000
	if year < -13800000000:
		year += 9223372023054775807
	update_time_hud()

func is_ground(x: int, y: int) -> bool:
	return $TileMap.get_cell(x, y) == 0

func set_floor_num(num: int) -> void:
	floor_num = num
	if floor_num == 0:
		width = 15
		height = 15
	else:
		width = 32 + 4 * floor_num
		height = 32 + 4 * floor_num

func descend() -> void:
	if floor_num == 15:
		get_tree().change_scene("res://scene/state/Win.tscn")
		return
	saved_entities[floor_num] = []
	for e in $Entities.get_children():
		saved_entities[floor_num].append([e.get_id(), e.get_map_x(), e.get_map_y()])
		e.queue_free()
	$TileMap.clear()
	set_floor_num(floor_num + 1)
	gen_map(true)

func ascend() -> void:
	saved_entities[floor_num] = []
	for e in $Entities.get_children():
		saved_entities[floor_num].append([e.get_id(), e.get_map_x(), e.get_map_y()])
		e.queue_free()
	$TileMap.clear()
	set_floor_num(floor_num - 1)
	gen_map(false)

func get_entity_at(x: int, y:int) -> Node:
	if $Player.is_at(x, y):
		return $Player
	for e in $Entities.get_children():
		if e.is_at(x, y):
			return e
	return null

func update_entities() -> void:
	increment_time()
	for e in $Entities.get_children():
		e.update()
