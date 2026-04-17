extends Control

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	SoundManager._play_chill_music()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Hub/Hub.tscn")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_reset_save_button_pressed() -> void:
	PartyManager.reset_save()

func _on_settings_button_pressed() -> void:
	$CanvasLayer/Panel/SettingsPanel.visible = true
