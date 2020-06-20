extends Node2D

const WIDTH: int = 64
const HEIGHT: int = 64
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

var second: int = 0
var minute: int = 0
var hour: int = 0
var day: int = 1
var month: int = 1
var year: int = 2020

func _ready() -> void:
	randomize()
	$Player.connect("tick", self, "update_entities")
	set_start_time()
	gen_map()

func gen_map() -> void:
	var region: Array = []
	for i in 4:
		var rect_w: int = 3 + (randi() % 5) * 2
		var rect_x: int = 1 + (randi() % ((WIDTH / 2 - rect_w - 1) / 2)) * 2
		if i % 2 == 1:
			rect_x += WIDTH / 2
		var rect_h: int = 3 + (randi() % 5) * 2
		var rect_y: int = 1 + (randi() % ((HEIGHT / 2 - rect_h - 1) / 2)) * 2
		if i > 1:
			rect_y += HEIGHT / 2
		region.append([rect_x, rect_y, rect_w, rect_h])
	for i in range(ROOM_ITERATIONS):
		var rect_w: int = 3 + (randi() % 5) * 2
		var rect_x: int = 1 + (randi() % ((WIDTH - rect_w - 1) / 2)) * 2
		var rect_h: int = 3 + (randi() % 5) * 2
		var rect_y: int = 1 + (randi() % ((HEIGHT - rect_h - 1) / 2)) * 2
		var is_valid: bool = true
		var j: int = 0
		while is_valid and j < region.size():
			if rect_x - 1 < region[j][0] + region[j][2] + 1 and rect_x + rect_w + 1 > region[j][0] - 1 and rect_y - 1 < region[j][1] + region[j][3] + 1 and rect_y + rect_h + 1 > region[j][1] - 1:
				is_valid = false
			j += 1
		if is_valid:
			region.append([rect_x, rect_y, rect_w, rect_h])
	var i: int = 0
	while i < region.size():
		for y in region[i][3]:
			for x in region[i][2]:
				$TileMap.set_cell(region[i][0] + x, region[i][1] + y, 0)
		i += 1
	for h in HEIGHT / 2:
		for w in WIDTH / 2:
			maze_gen(w * 2 + 1, h * 2 + 1, region)
	add_doors(region)
	#flood_check()
	var dead_ends: Array = get_dead_ends()
	while dead_ends.size() != 0:
		for d in dead_ends:
			$TileMap.set_cell(d[0], d[1], -1)
		dead_ends = get_dead_ends()

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
		if y + 2 <= HEIGHT and $TileMap.get_cell(x, y + 2) != 0:
			walls.append([x, y + 2])
		if x - 2 >= 0 and $TileMap.get_cell(x - 2, y) != 0:
			walls.append([x - 2, y])
		if x + 2 <= WIDTH and $TileMap.get_cell(x + 2, y) != 0:
			walls.append([x + 2, y])
		while !walls.empty():
			var index: int = randi() % walls.size()
			var w: Array = walls[index]
			walls.remove(index)
			$TileMap.set_cell(w[0], w[1], 0)
			var needs_wall: bool = true
			var dir: Array = [0, 1, 2, 3]
			while needs_wall and dir.size() > 0:
				var dir_index: int = randi() % dir.size()
				match dir[dir_index]:
					0:
						if w[0] - 2 >= 0 and $TileMap.get_cell(w[0] - 2, w[1]) == 0 and !is_in_room(w[0] - 2, w[1], rooms):
							$TileMap.set_cell(w[0] - 1, w[1], 0)
							needs_wall = false
					1:
						if w[0] + 2 <= WIDTH and $TileMap.get_cell(w[0] + 2, w[1]) == 0 and !is_in_room(w[0] + 2, w[1], rooms):
							$TileMap.set_cell(w[0] + 1, w[1], 0)
							needs_wall = false
					2:
						if w[1] - 2 >= 0 and $TileMap.get_cell(w[0], w[1] - 2) == 0 and !is_in_room(w[0], w[1] - 2, rooms):
							$TileMap.set_cell(w[0], w[1] - 1, 0)
							needs_wall = false
					3:
						if w[1] + 2 <= HEIGHT and $TileMap.get_cell(w[0], w[1] + 2) == 0 and !is_in_room(w[0], w[1] + 2, rooms):
							$TileMap.set_cell(w[0], w[1] + 1, 0)
							needs_wall = false
				dir.remove(dir_index)
			if !needs_wall:
				if w[1] - 2 >= 0 and $TileMap.get_cell(w[0], w[1] - 2) != 0 and !walls.has([w[0], w[1] - 2]):
					walls.append([w[0], w[1] - 2])
				if w[1] + 2 <= HEIGHT and $TileMap.get_cell(w[0], w[1] + 2) != 0 and !walls.has([w[0], w[1] + 2]):
					walls.append([w[0], w[1] + 2])
				if w[0] - 2 >= 0 and $TileMap.get_cell(w[0] - 2, w[1]) != 0 and !walls.has([w[0] - 2, w[1]]):
					walls.append([w[0] - 2, w[1]])
				if w[0] + 2 <= WIDTH and $TileMap.get_cell(w[0] + 2, w[1]) != 0 and !walls.has([w[0] + 2, w[1]]):
					walls.append([w[0] + 2, w[1]])

func add_doors(rooms: Array) -> void:
	for r in rooms:
		var dirs: PoolIntArray = [0, 1, 2, 3]
		if r[0] >= WIDTH - 1:
			dirs.remove(3)
		if r[0] <= 1:
			dirs.remove(2)
		if r[1] >= HEIGHT - 1:
			dirs.remove(1)
		if r[1] >= 1:
			dirs.remove(0)
		var side: int = dirs[randi() % dirs.size()]
		if side == 0 || dirs[randi() % dirs.size()] == 0:
			for x in r[2]:
				if $TileMap.get_cell(r[0] + (x + r[2] / 2) % r[2], r[1] - 2) == 0:
					$TileMap.set_cell(r[0] + (x + r[2] / 2) % r[2], r[1] - 1, 0)
					break
		if side == 1 || dirs[randi() % dirs.size()] == 1:
			for x in r[2]:
				if $TileMap.get_cell(r[0] + (x + r[2] / 2) % r[2], r[1] + r[3] + 1) == 0:
					$TileMap.set_cell(r[0] + (x + r[2] / 2) % r[2], r[1] + r[3], 0)
					break
		if side == 2 || dirs[randi() % dirs.size()] == 2:
			for y in r[3]:
				if $TileMap.get_cell(r[0] - 2, r[1] + (y + r[3] / 2) % r[3]) == 0:
					$TileMap.set_cell(r[0] - 1, r[1] + (y + r[3] / 2) % r[3], 0)
					break
		if side == 3 || dirs[randi() % dirs.size()] == 3:
			for y in r[3]:
				if $TileMap.get_cell(r[0] + r[2] + 1, r[1] + (y + r[3] / 2) % r[3]) == 0:
					$TileMap.set_cell(r[0] + r[2], r[1] + (y + r[3] / 2) % r[3], 0)
					break

func flood_check() -> void:
	var q: Array = []
	var visited: Array = []
	var v: int = 0
	for i in WIDTH * HEIGHT:
		if $TileMap.get_cell(i % WIDTH, i / WIDTH) == 0:
			q.append([i % WIDTH, i / WIDTH])
			visited.append([i % WIDTH, i / WIDTH])
			break
	while !q.empty():
		while !q.empty():
			var n: Array = q.pop_front()
			if n[0] - 1 >= 0 and !visited.has([n[0] - 1, n[1]]) and $TileMap.get_cell(n[0] - 1, n[1]) == 0:
				q.append([n[0] - 1, n[1]])
				visited.append([n[0] - 1, n[1]])
			if n[0] + 1 <= WIDTH and !visited.has([n[0] + 1, n[1]]) and $TileMap.get_cell(n[0] + 1, n[1]) == 0:
				q.append([n[0] + 1, n[1]])
				visited.append([n[0] + 1, n[1]])
			if n[1] - 1 >= 0 and !visited.has([n[0], n[1] - 1]) and $TileMap.get_cell(n[0], n[1] - 1) == 0:
				q.append([n[0], n[1] - 1])
				visited.append([n[0], n[1] - 1])
			if n[1] + 1 <= HEIGHT and !visited.has([n[0], n[1] + 1]) and $TileMap.get_cell(n[0], n[1] + 1) == 0:
				q.append([n[0], n[1] + 1])
				visited.append([n[0], n[1] + 1])
		while v < visited.size():
			if visited[v][0] - 2 >= 0 and $TileMap.get_cell(visited[v][0] - 1, visited[v][1]) != 0 and $TileMap.get_cell(visited[v][0] - 2, visited[v][1]) == 0 and !visited.has([visited[v][0] - 2, visited[v][1]]):
				$TileMap.set_cell(visited[v][0] - 1, visited[v][1], 0)
				q.append([visited[v][0] - 1, visited[v][1]])
				visited.append([visited[v][0] - 1, visited[v][1]])
				break
			if visited[v][0] + 2 <= WIDTH and $TileMap.get_cell(visited[v][0] + 1, visited[v][1]) != 0 and $TileMap.get_cell(visited[v][0] + 2, visited[v][1]) == 0 and !visited.has([visited[v][0] + 2, visited[v][1]]):
				$TileMap.set_cell(visited[v][0] + 1, visited[v][1], 0)
				q.append([visited[v][0] + 1, visited[v][1]])
				visited.append([visited[v][0] + 1, visited[v][1]])
				break
			if visited[v][1] - 2 >= 0 and $TileMap.get_cell(visited[v][0], visited[v][1] - 1) != 0 and $TileMap.get_cell(visited[v][0], visited[v][1] - 2) == 0 and !visited.has([visited[v][0], visited[v][1] - 2]):
				$TileMap.set_cell(visited[v][0], visited[v][1] - 1, 0)
				q.append([visited[v][0], visited[v][1] - 1])
				visited.append([visited[v][0], visited[v][1] - 1])
				break
			if visited[v][1] + 2 <= HEIGHT and $TileMap.get_cell(visited[v][0], visited[v][1] + 1) != 0 and $TileMap.get_cell(visited[v][0], visited[v][1] + 2) == 0 and !visited.has([visited[v][0], visited[v][1] + 2]):
				$TileMap.set_cell(visited[v][0], visited[v][1] + 1, 0)
				q.append([visited[v][0], visited[v][1] + 1])
				visited.append([visited[v][0], visited[v][1] + 1])
				break
			v += 1

func get_dead_ends() -> Array:
	var result: Array = []
	for y in HEIGHT:
		for x in WIDTH:
			if $TileMap.get_cell(x, y) == 0:
				var neighbors: int = 0
				if x - 1 >= 0 and $TileMap.get_cell(x - 1, y) == 0:
					neighbors += 1
				if x + 1 <= WIDTH and $TileMap.get_cell(x + 1, y) == 0:
					neighbors += 1
				if y - 1 >= 0 and $TileMap.get_cell(x, y - 1) == 0:
					neighbors += 1
				if y + 1 <= HEIGHT and $TileMap.get_cell(x, y + 1) == 0:
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
	if year < -13800000000:
		year += 9223372023054775807
	update_time_hud()

func update_entities() -> void:
	increment_time()
	for e in $Entities.get_children():
		e.update()
