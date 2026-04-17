extends RichTextLabel
class_name GameConsole

static var instance: GameConsole

func _ready():
	# Register this specific node as the global instance
	instance = self
	
	# Visibility logic
	visible = (get_parent().name == "BattleUI")
	bbcode_enabled = true

# To make it accessible from any script script without being a singleton
static func log_message(category: String, message: String):
	if instance:
		var formatted = "[color=red]%s[/color] \t %s\n" % [category.to_upper(), message]
		
		instance.append_text(formatted)
		instance.call_deferred("_scroll_to_bottom")

func _scroll_to_bottom():
	var v_scroll = get_v_scroll_bar()
	v_scroll.value = v_scroll.max_value
