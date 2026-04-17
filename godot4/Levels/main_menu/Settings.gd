extends Panel
@onready var back_button = %BackButton
@onready var superquit_button = %SuperQuitButton
@onready var current_level = get_tree().current_scene.name

@onready var master_volume = %MasterVolume
@onready var music_volume = %MusicVolume
@onready var sfx_volume = %SFXVolume

func _ready():
	var current_level = get_tree().current_scene.name
	#sync sliders to the values stored in the Singleton to make slider changes persist throughout scene changes
	master_volume.value = SoundManager.master_volume
	music_volume.value = SoundManager.music_volume
	sfx_volume.value = SoundManager.sfx_volume
	
	if current_level == "MainMenu":
		superquit_button.visible = false
	else:
		superquit_button.visible = true

func _on_back_button_pressed() -> void:
	self.visible = false

func _on_super_quit_button_pressed() -> void:
	get_tree().quit()

func _on_master_volume_value_changed(value: float) -> void:
	SoundManager._on_master_slider_value_changed(value)

func _on_sfx_volume_value_changed(value: float) -> void:
	SoundManager._on_sfx_slider_value_changed(value)

func _on_music_volume_value_changed(value: float) -> void:
	SoundManager._on_music_slider_value_changed(value)
