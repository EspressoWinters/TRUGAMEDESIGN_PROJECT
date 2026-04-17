extends RichTextLabel
class_name GameConsole

static var instance: GameConsole

func _ready():
	#makes this specific node as the global instance
	instance = self
	
	visible = (get_parent().name == "BattleUI")
	bbcode_enabled = true

#to make it accessible from any script script without being a singleton. this makes it easier to manage from the ui scene while being able to be used by other scripts
static func log_message(category: String, message: String):
	if instance:
		var formatted = "[color=red]%s[/color] \t %s\n" % [category.to_upper(), message]
		
		instance.append_text(formatted)
		instance.call_deferred("_scroll_to_bottom")

func _scroll_to_bottom():
	var v_scroll = get_v_scroll_bar()
	v_scroll.value = v_scroll.max_value
