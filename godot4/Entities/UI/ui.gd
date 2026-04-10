extends Control

signal move_requested
signal attack_requested
signal end_turn_requested
signal ability_requested
@onready var timer := $Timer
var can_next_turn : bool = true

func _on_move_button_pressed() -> void:
	move_requested.emit()

func _on_ability_button_pressed() -> void:
	ability_requested.emit()

func _on_attack_button_pressed() -> void:
	attack_requested.emit()

func _on_end_turn_button_pressed() -> void:
	if can_next_turn:
		end_turn_requested.emit()
		can_next_turn = false
		timer.start()

func _on_timer_timeout() -> void:
	can_next_turn = true
