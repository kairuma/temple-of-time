extends Node2D

const WIDTH: int = 64
const HEIGHT: int = 64
const ROOM_ITERATIONS: int = 1
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
var map_data: PoolIntArray = []

func _ready() -> void:
	randomize()
	$Player.connect("tick", self, "update_entities")
	set_start_time()
	for i in 64:
		gen_map()

func gen_map() -> void:
	var region: Array = []
	for i in WIDTH * HEIGHT:
		map_data.append(0)
	for q in range(1):
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
	print(region)
	for r in region:
		for y in r[3]:
			for x in r[2]:
				$TileMap.set_cell(r[0] + x, r[1] + y, 0)

func update_time_hud() -> void:
	var time_str: String = ""
	var year_str: String = str(year)
	if year < 0:
		year_str = "%d BC" % -year
	if Global.display_hour_24():
		time_str = "%s %02d, %s; %02d : %02d : %02d" % [MONTH_NAME[month], day, year_str, hour, minute, second]
	else:
		if hour == 0:
			time_str = "%s %02d, %s; 12 : %02d : %02d AM" % [MONTH_NAME[month], day, year_str, minute, second]
		elif hour < 12:
			time_str = "%s %02d, %s; %02d : %02d : %02d AM" % [MONTH_NAME[month], day, year_str, hour, minute, second]
		elif hour == 12:
			time_str = "%s %02d, %s; 12 : %02d : %02d PM" % [MONTH_NAME[month], day, year_str, minute, second]
		else:
			time_str = "%s %02d, %s; %02d : %02d : %02d PM" % [MONTH_NAME[month], day, year_str, hour - 12, minute, second]
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
