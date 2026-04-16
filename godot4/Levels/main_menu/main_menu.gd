extends Control

func _ready():
	SoundManager._play_chill_music()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Hub/Hub.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_reset_save_button_pressed() -> void:
	PartyManager.reset_save()
