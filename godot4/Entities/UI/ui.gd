extends Control

signal move_requested
signal attack_requested
signal end_turn_requested
signal ability_requested

@onready var combat_end_ui: Panel = $CanvasLayer/CombatEndUi
@onready var continue_button_ui: Button = $CanvasLayer/CombatEndUi/ContinueButton
@onready var battle_ui: Panel = $CanvasLayer/BattleUI
@onready var combat_end_label_ui = $CanvasLayer/CombatEndUi/Label

func _on_move_button_pressed() -> void:
	move_requested.emit()

func _on_ability_button_pressed() -> void:
	ability_requested.emit()

func _on_attack_button_pressed() -> void:
	attack_requested.emit()

func _on_end_turn_button_pressed() -> void:
	end_turn_requested.emit()

func _on_continue_button_pressed() -> void:
	PartyManager.save_party()
	get_tree().paused = false
	LevelManager.advance_level()
	get_tree().change_scene_to_file(LevelManager.get_current_level_path())

func _on_base_button_pressed() -> void:
	PartyManager.save_party()
	get_tree().paused = false
	LevelManager.reset_progression()
	get_tree().change_scene_to_file("res://Levels/Hub/Hub.tscn")
