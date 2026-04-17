extends Node
#credits to this youtube video: https://www.youtube.com/watch?v=F0DQLSiLkjg

func display_number(value: int, position: Vector2, is_critical: bool = false):
	var number = Label.new()
	var offset = Vector2(-4, -10)
	# Set basic text properties
	number.text = str(abs(value))
	
	number.global_position = position + offset
	number.z_index = 5
	
	var settings = LabelSettings.new()
	var text_to_display = str(abs(value))
	if is_critical:
		text_to_display += "!!!"
	number.text = text_to_display
	#this handles the color of the damage
	var color = Color.WHITE
	if is_critical:
		color = Color.RED
	elif value == 0:
		color = Color.BLACK
	elif value < 0:
		color = Color.GREEN    #negative numbers show as green for healing
	
	settings.font_color = color
	if is_critical:
		settings.font_size = 20
	else:
		settings.font_size = 12
	settings.outline_color = Color.BLACK
	settings.outline_size = 2
	number.label_settings = settings
	
	#adds the number to the scene
	add_child(number)
	
	#we wait one frame so Godot calculates the Label's actual size.
	await get_tree().process_frame
	number.pivot_offset = number.size / 2
	
	#animates the text
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	#pop up animation
	tween.tween_property(
		number, "position:y", number.position.y - 24, 0.25
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUINT)
	
	#fall back down after the pop up animation
	tween.tween_property(
		number, "position:y", number.position.y, 0.5
	).set_ease(Tween.EASE_IN).set_delay(0.25)
	
	#shrink to nothing
	tween.tween_property(
		number, "scale", Vector2.ZERO, 0.25
	).set_ease(Tween.EASE_IN).set_delay(0.5)
	
	#gets rid of the number after it is done displaying
	await tween.finished
	number.queue_free()
