extends Control


@onready var party_manager_ui : Panel = $CanvasLayer/TextureRect/PartyManager
@onready var current_party_vbox : VBoxContainer = $CanvasLayer/TextureRect/PartyManager/CurrentPartyPanel/CurrentPartyList
@onready var recruit_vbox : VBoxContainer = $CanvasLayer/TextureRect/PartyManager/RecruitableHerosPanel/RecruitableHerosList
@onready var info_name_label : Label = $CanvasLayer/TextureRect/PartyManager/HeroInfo/Label
@onready var info_stats_label : RichTextLabel = $CanvasLayer/TextureRect/PartyManager/HeroInfo/RichTextLabel

func _ready() -> void:
	for unit in PartyManager.active_party:
		unit.current_health = unit.max_hp
	party_manager_ui.visible = false
	
	
func _on_hero_manager_building_pressed() -> void:
	party_manager_ui.visible = true
	#if the pool is empty (first time opening) tells PartyManager to fill it
	if PartyManager.available_to_hire.is_empty():
		PartyManager.refresh_hiring_pool()
	refresh_ui()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_close_HiringUI_button_pressed() -> void:
	party_manager_ui.visible = false
	
func refresh_ui() -> void:
	#clear and rebuild both lists from the partydata 
	_populate_list(current_party_vbox, PartyManager.active_party, false)
	_populate_list(recruit_vbox, PartyManager.available_to_hire, true)

func _populate_list(container: VBoxContainer, data_array: Array, is_hiring_list: bool) -> void:
	for child in container.get_children():
		child.queue_free()
	
	for i in range(data_array.size()):
		var hero = data_array[i] as Unit_Interaction
		if hero:
			var btn = Button.new()
			
			#use the role variable fallsback to filename if role is empty
			var display_name = hero.role
			if display_name == "":
				display_name = hero.resource_path.get_file().get_basename()
			
			btn.text = display_name
			btn.alignment = HorizontalAlignment.HORIZONTAL_ALIGNMENT_LEFT
			container.add_child(btn)
			
			btn.pressed.connect(_on_hero_selected.bind(hero, display_name, i, is_hiring_list))

func _on_hero_selected(hero: Unit_Interaction, d_name: String, index: int, is_hiring_list: bool) -> void:
	#update labels
	info_name_label.text = d_name
	info_stats_label.text = "Attributes\nLVL: %d\nHP: %d\nATK: %d\nDEF: %d\nSPD: %d\n\nDescription:\n%s\n\n%s\n\n%s" % [
		hero.level, hero.max_hp, hero.attack_stat, hero.defense, hero.speed, hero.atk_explain, hero.ability_explain, hero.passive_explain
	]
	
	var hire_btn = $CanvasLayer/TextureRect/PartyManager/RecruitableHerosPanel/HireButton
	var fire_btn = $CanvasLayer/TextureRect/PartyManager/CurrentPartyPanel/FireButton
	
	if hire_btn.pressed.is_connected(_on_hire_confirmed): hire_btn.pressed.disconnect(_on_hire_confirmed)
	if fire_btn.pressed.is_connected(_on_fire_confirmed): fire_btn.pressed.disconnect(_on_fire_confirmed)
	
	#shows only one button at a time
	if is_hiring_list:
		hire_btn.visible = true
		fire_btn.visible = false
		hire_btn.pressed.connect(_on_hire_confirmed.bind(index))
	else:
		fire_btn.visible = true
		hire_btn.visible = false
		fire_btn.pressed.connect(_on_fire_confirmed.bind(index))

func _on_hire_confirmed(index: int) -> void:
	#prevents game from crashing from array being out of bound
	if index == -1 or index >= PartyManager.available_to_hire.size():
		return
		
	var hero_to_hire = PartyManager.available_to_hire[index]
	if PartyManager.hire_unit(hero_to_hire):
		PartyManager.available_to_hire.remove_at(index)
		refresh_ui()
		info_name_label.text = "Unit Recruited"
		info_stats_label.text = ""

func _on_fire_confirmed(index: int) -> void:
	PartyManager.fire_unit(index)
	refresh_ui()
	info_name_label.text = "Unit Dismissed"
	info_stats_label.text = ""

func _on_expedition_button_pressed() -> void:
	for unit in PartyManager.active_party:
		unit.current_health = unit.max_hp
	SoundManager._play_battle_music()
	get_tree().change_scene_to_file("res://Levels/Level_0_plains.tscn")

func _on_training_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Tutorialz.tscn")
