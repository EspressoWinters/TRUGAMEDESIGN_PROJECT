extends Control

signal move_requested
signal attack_requested
signal end_turn_requested
signal ability_requested
@onready var timer := $Timer
var can_next_turn : bool = true

@onready var combat_end_ui: Panel = $CanvasLayer/CombatEndUi
@onready var continue_button_ui: Button = $CanvasLayer/CombatEndUi/ContinueButton
@onready var battle_ui: Panel = $CanvasLayer/BattleUI
@onready var combat_end_label_ui = $CanvasLayer/CombatEndUi/Label
@onready var backtohub_ui = $BackToHubButton
@onready var settings_ui = %SettingsPanel
@onready var attackbutton_ui =$CanvasLayer/BattleUI/HBoxCharacterMoves/AttackButton
@onready var turn_bar_container = $CanvasLayer/TurnOrder/HBoxContainer
@onready var PartyXpInfo = $CanvasLayer/CombatEndUi/PartyXPInfo
@onready var turnorder_ui = $CanvasLayer/TurnOrder

func _ready() -> void:
	var current_level = get_tree().current_scene.name
	if current_level == "Tutorialz":
		backtohub_ui.visible = true
	else:
		backtohub_ui.visible = false

func _on_move_button_pressed() -> void:
	move_requested.emit()

func _on_ability_button_pressed() -> void:
	ability_requested.emit()

func _on_attack_button_pressed() -> void:
	attack_requested.emit()

func _on_end_turn_button_pressed() -> void:
	if can_next_turn:
		end_turn_requested.emit()
		#can_next_turn = false
		#timer.start()

#func _on_timer_timeout() -> void:
	#can_next_turn = true
	#end_turn_requested.emit()

func _on_continue_button_pressed() -> void:
	var survivors = get_tree().get_nodes_in_group("player_units")
	PartyManager.update_and_save_party_from_nodes(survivors)
	get_tree().paused = false
	LevelManager.advance_level()
	get_tree().change_scene_to_file(LevelManager.get_current_level_path())

func _on_base_button_pressed() -> void:
	var survivors = get_tree().get_nodes_in_group("player_units")
	PartyManager.update_and_save_party_from_nodes(survivors)
	get_tree().paused = false
	LevelManager.reset_progression()
	SoundManager._play_chill_music()
	get_tree().change_scene_to_file("res://Levels/Hub/Hub.tscn")

func _on_back_to_hub_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Levels/Hub/Hub.tscn")


func _on_settings_button_pressed() -> void:
	settings_ui.visible = true

func refresh_turn_bar(initiative_order: Array, current_index: int):
	#clears the old sprites when function is called again
	for child in turn_bar_container.get_children():
		child.queue_free()
	
	#this sets the max amount of sprites to be displayed for turn order
	var max_display = 10
	var display_count = min(initiative_order.size(), max_display)
	
	#loops through the initiative array
	for i in range(display_count):
		#this calulates the wrap-around index
		var idx = (current_index + i) % initiative_order.size()
		var unit = initiative_order[idx]
		
		#creates a new texture rect
		var new_icon = TextureRect.new()
		
		#assigns the sprite to the texturerect
		if unit.unit_role and unit.unit_role.skin:
			new_icon.texture = unit.unit_role.skin
		
		#this is to configure the sprite scaling
		new_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		new_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		new_icon.mouse_filter = Control.MOUSE_FILTER_STOP
		
		#makes it more obvious who the current unit is vs upcoming units
		if i == 0:
			new_icon.modulate = Color(1, 1, 1) #adjust the sprites see through ness of current unit
			new_icon.custom_minimum_size = Vector2(24, 24) #adjusts the sprite size of current unit
		else:
			new_icon.modulate = Color(0.6, 0.6, 0.6) #adjust the sprites see through ness of upcoming units
			new_icon.custom_minimum_size = Vector2(16, 16) #adjusts the sprite size of upcoming units
			
		#adds the texturerect to the Hboxcontrainer
		turn_bar_container.add_child(new_icon)
		
		#connects the mouse entered function to the sprite
		new_icon.mouse_entered.connect(func(): 
			if is_instance_valid(unit):
				unit.set_glow(true)
		)
		
		#connects the mouse exited function to the sprite
		new_icon.mouse_exited.connect(func(): 
			if is_instance_valid(unit):
				unit.set_glow(false)
		)

#this for the end screen to display xp and levels and stuffs
func display_combat_results():
	PartyXpInfo.text = ""
	var party_members = get_tree().get_nodes_in_group("player_units")
	
	if party_members.is_empty():
		PartyXpInfo.append_text("[center][color=red]No survivors found.[/color][/center]")
		return
	
	var final_text = "[center][b][color=gold]BATTLE STATS[/color][/b][/center]\n\n"
	
	for node in party_members:
		if not node is Unit or not is_instance_valid(node): 
			continue
			
		var unit = node
		var role_data = unit.unit_role
		
		var role_name = role_data.role if role_data.role != "" else "Recruit"
		
		var lvl = role_data.level 
		var cur_xp = role_data.xp
		
		var unit_line = "[b]%s[/b]\n" % role_name
		unit_line += "  [color=gray]LVL:[/color] %d | [color=gray]XP:[/color] %d\n\n" % [lvl, cur_xp]
		final_text += unit_line
	
	PartyXpInfo.append_text(final_text)
