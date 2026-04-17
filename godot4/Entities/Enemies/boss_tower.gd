#This is the basic enemy script, this will be the most basic enemy, the enemy will try to get to the closet player and then attack them
#I will be retrofitting a lot of the unit's script
#keeping the stat system for the enemy, we could then play around and have different enemies with the differing stats 

#this allows us to run it in the editor
@tool
class_name BossTower
#we are extending the unit and now we have access to all the unit's functions and variables 
#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html if you need a reference on inheritance 
extends Unit 

#going to keep an array of all human players, so that we can keep track of those pesky humans 
var human_units := []
var tank_units := []
#hold the value of the closest unit 
var closest_unit : Unit
var taunter_found := false

#it probably needs some attackable cells, like the unit  
var attackable_human_cells : Array = []
#I JUST ADDED THIS 
#Credit to this lad for showing us how to make unique resources
#https://simondalvai.org/blog/godot-duplicate-resources/
func _ready() -> void:
	#to make it unique copy it own?
	unit_role = unit_role.duplicate()
	
	
	sprite.texture = unit_role.skin
	move_range = unit_role.speed
	move_speed = unit_role.speed * 100
	max_health = unit_role.max_hp
	if unit_role is Basic_enemy or unit_role is Hunter_enemy or unit_role is Big_enemy or unit_role is Boss_Tower:
		unit_role.current_health = max_health
	
	#makes sure the object doesn't start the _process function
	set_process(false)
	#locks it so it doesn't rotate along the path
	#basically instead of looking statically at one side, it would "follow" the direction of the path and rotate itself
	_path_follow.rotates = false 
	#just getting the pixel and the grid values so that we can use them later
	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	var _health_bar = get_node_or_null("Healthbar")
	
	_health_bar.max_value = max_health
	_health_bar.value = unit_role.current_health
	await get_tree().process_frame
	gameboard._update_health_bar.connect(set_health_bar)

func get_attack_range(origin_cell: Vector2) -> Array:
	
	#should clear the bloody thing 
	attackable_human_cells.clear()
	
	var cell
	
		
	#just using the grenadier code again but extending the range
	#we've came to a consensus that the tower range compared to the grenadier range  
	for x in range(-6, 7):
		for y in range(-6, 7):
			cell = origin_cell + Vector2(x, y)
			#trying to avoid duplicates because had issue with duplicats 
			if cell not in attackable_human_cells:
				attackable_human_cells.append(cell)
		
		
	return attackable_human_cells 
