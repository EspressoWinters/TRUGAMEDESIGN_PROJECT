extends Node

var current_level_index: int = 0

# List of the level scenes in order
var level_playlist: Array[String] = [
	"res://Levels/Level_0_plains.tscn",
	"res://Levels/Level_1_rivers.tscn",
	"res://Levels/Level_2_ruin_ambush.tscn",
	"res://Levels/Level_3_ruins.tscn",
	"res://Levels/Level_4_bridge.tscn"
]

func get_current_level_path() -> String:
	if current_level_index < level_playlist.size():
		return level_playlist[current_level_index]
	return ""

func advance_level() -> void:
	current_level_index += 1

func reset_progression() -> void:
	current_level_index = 0
