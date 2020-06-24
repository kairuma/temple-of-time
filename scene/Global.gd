extends Node

var new_game: bool = true setget set_new_game, is_new_game
var hour_24: bool = false setget set_hour_24, is_hour_24

func _ready() -> void:
	load_config()

func load_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load("user://config.ini")
	hour_24 = config.get_value("options", "hour_24", false)
	if !config.has_section_key("options", "hour_24"):
		config.set_value("options", "hour_24", false)
	config.save("user://config.ini")

func save_config() -> void:
	var config: ConfigFile = ConfigFile.new()
	config.load("user://config.ini")
	config.set_value("options", "hour_24", hour_24)
	config.save("user://config.ini")

func save_game() -> void:
	var nodes: Array = get_tree().get_nodes_in_group("Map")
	if nodes.size() != 1:
		return
	var map_node: Node = nodes[0]
	var time: Dictionary = map_node.get_time()
	var save_data: Dictionary = {
		"floor_num": map_node.get_floor_num(), 
		"player_x": map_node.get_player_x(), 
		"player_y": map_node.get_player_y(), 
		"player_hp": map_node.get_player_hp(), 
		"entities": map_node.get_saved_entities(), 
		"time": time, 
	}
	var save_file: File = File.new()
	save_file.open("user://player.sav", File.WRITE)
	save_file.store_line(to_json(save_data))
	save_file.store_line(str(map_node.get_world_seed()))
	save_file.store_line(str(time["year"]))
	save_file.close()

func delete_save() -> void:
	var dir: Directory = Directory.new()
	dir.remove("user://player.sav")

func set_new_game(b: bool) -> void:
	new_game = b

func is_new_game() -> bool:
	return new_game

func set_hour_24(b: bool) -> void:
	hour_24 = b

func is_hour_24() -> bool:
	return hour_24
