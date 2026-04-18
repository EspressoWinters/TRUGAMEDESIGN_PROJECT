#Ending the game if the end button is pressed 
extends Control



func _on_button_pressed() -> void:
	get_tree().quit()
