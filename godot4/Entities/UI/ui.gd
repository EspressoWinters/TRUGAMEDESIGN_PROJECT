extends Control

signal move_requested
signal attack_requested
signal end_turn_requested

func _on_move_button_pressed() -> void:
	move_requested.emit()

func _on_ability_button_pressed() -> void:
	pass

func _on_attack_button_pressed() -> void:
	attack_requested.emit()

func _on_end_turn_button_pressed() -> void:
	end_turn_requested.emit()
