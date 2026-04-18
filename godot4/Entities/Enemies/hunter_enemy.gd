#The is the hunter enemy, it will target weaker units and then kill them based on a calculation of how low the player is and there class 

#this allows us to run it in the editor
@tool
class_name HunterEnemy
#we are extending the unit and now we have access to all the unit's functions and variables 
#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html if you need a reference on inheritance 
extends Unit 

#going to keep an array of all human players, so that we can keep track of those pesky humans 
var human_units := []
var tank_units := []
#hold the value of the closest unit 
var closest_unit : Unit
var taunter_found := false


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
	if unit_role is Basic_enemy or unit_role is Hunter_enemy or unit_role is Big_enemy:
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


#let's create a function to find the closet player character
func find_closet_human_character():
	var highest_score_unit : Unit
	#error and debugging portion
	if gameboard._units.is_empty():
		print("Roger roger, there are no humans on the board!")
		#exit the function to prevent crash
		return 
	
	human_units.clear() #needed to prevent the array from keeping duplicate units
	tank_units.clear() #needed for same reason as above
	var taunter_found := false #needed to reset the bool every turn

	#let's get all the units that are human in the array
	for unit in gameboard._units.values():
		if unit is not BasicEnemy and unit is not HunterEnemy and unit is not BigEnemy and unit is not Tower  and unit is not BossMain and unit is not BossTower:
			human_units.append(unit)
			if unit.unit_role and unit.unit_role is Tank and unit.is_taunting:
				taunter_found = true
				tank_units.append(unit)
	#now we need to calculate the who is the closest 
	#we are using Manhattan distance = | X1 - X2 | + | Y1 - Y2 |, not Eucledian as that would get us errors 
	#our A* algorithm use Manhattan distances for context
	
	#this is what will be holding the values of the unit's temporarily 
	var temp_distance : int 
	
	if taunter_found:
		highest_score_unit = Highest_Score_Player_Unit(tank_units)

	else:
		highest_score_unit = Highest_Score_Player_Unit(human_units)	
	#gathering which human unit has the least amount of distance
	temp_distance = abs(highest_score_unit.cell.x - self.cell.x) + abs(highest_score_unit.cell.y - self.cell.y)
	if temp_distance <= 1:
		return null
	
	return highest_score_unit
		
		
func check_and_attack_adjacent():
	for unit in gameboard._units.values():
		if unit is BasicEnemy or unit is HunterEnemy or unit is BigEnemy or unit is BossMain or unit is BossTower or unit is Tower: continue
		
		#calculate distance from our NEW position (self.cell)
		var d = abs(unit.cell.x - self.cell.x) + abs(unit.cell.y - self.cell.y)
		
		if d <= 1:
			VfxManager.play_vfx("slash_attack", unit.global_position)
			gameboard.apply_damage(unit.cell, unit_role.attack_roll(self), self, unit_role.crit)
			

#The hunter gets its value for what it wants to prioritize 
func Highest_Score_Player_Unit(Human_units: Array):
	var max_score = -10000
	
	var max_unit: Unit
	
	for unit in Human_units:
		var temp_score = 0
		if unit.unit_role is Tank:
			temp_score -= 3
		elif unit.unit_role is Flamethrower: 
			temp_score -=2
		elif unit.unit_role is Medic: 
			temp_score += 1
		elif unit.unit_role is Grenadier: 
			temp_score += 3
		elif unit.unit_role is Musketeer: 
			temp_score += 0
		else: print ("What unit is this?")
		temp_score -= unit.unit_role.current_health
		
		#print(temp_score)
		
		if temp_score > max_score:
			max_score = temp_score
			max_unit = unit
	#print ("MAx Unit: ",max_unit)
	return max_unit
	
