extends Node2D

const WIDTH: int = 64
const HEIGHT: int = 64
const ROOM_ITERATIONS: int = 256
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
	for i in range(ROOM_ITERATIONS):
		var rect_w: int = 3 + (randi() % 7) * 2
		var rect_x: int = 1 + (randi() % ((WIDTH - rect_w - 1) / 2)) * 2
		var rect_h: int = 3 + (randi() % 7) * 2
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
		var add_connection: bool = false
		for y in region[i][3]:
			for x in region[i][2]:
				add_connection = $TileMap.get_cell(region[i][0] + x, region[i][1] + y) != 0
				$TileMap.set_cell(region[i][0] + x, region[i][1] + y, 0)
		i += 1
		if add_connection and i < region.size():
			var start_x: int = region[i - 1][0] + randi() % region[i - 1][2]
			var start_y: int = region[i - 1][1] + randi() % region[i - 1][3]
			var end_x: int = region[i][0] + randi() % region[i][2]
			var end_y: int = region[i][1] + randi() % region[i][3]
			while start_x < end_x:
				$TileMap.set_cell(start_x, start_y, 0)
				start_x += 1
			while start_x > end_x:
				$TileMap.set_cell(start_x, start_y, 0)
				start_x -= 1
			while start_y < end_y:
				$TileMap.set_cell(start_x, start_y, 0)
				start_y += 1
			while start_y > end_y:
				$TileMap.set_cell(start_x, start_y, 0)
				start_y -= 1

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
