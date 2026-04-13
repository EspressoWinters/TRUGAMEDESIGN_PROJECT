#This is the basic enemy script, this will be the most basic enemy, the enemy will try to get to the closet player and then attack them
#I will be retrofitting a lot of the unit's script
#keeping the stat system for the enemy, we could then play around and have different enemies with the differing stats 

#this allows us to run it in the editor
@tool
class_name BasicEnemy
#we are extending the unit and now we have access to all the unit's functions and variables 
#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html if you need a reference on inheritance 
extends Unit 

#going to keep an array of all human players, so that we can keep track of those pesky humans 
var human_units := []
var tank_units := []
#hold the value of the closest unit 
var closest_unit : Unit
var taunter_found := false

#going to go for a hail mary here and just put this code here
#current plan, may get rid of this later, just commenting for myself
#keep _process because that is what is actually moving the character along the path 
#keep _ready as that is just calculating the movement speed and making sure the process is not setting off instantly
#keep walk_along as it is just keeping the curve that the path it will follow

#let's create a function to find the closet player character
func find_closet_human_character():
	
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
		if unit is not BasicEnemy and unit is not HunterEnemy and unit is not BigEnemy and unit is not Tower:
			human_units.append(unit)
			if unit.unit_role and unit.unit_role is Tank and unit.is_taunting:
				taunter_found = true
				tank_units.append(unit)
	
	
	
	#now we need to calculate the who is the closest 
	#we are using Manhattan distance = | X1 - X2 | + | Y1 - Y2 |, not Eucledian as that would get us errors 
	#our A* algorithm use Manhattan distances for context
	
	#creating variable to hold the distance of the unit
	#just making it a really high number so that it will always "lose" the comparsion
	var least_distance := 1000
	#this is what will be holding the values of the unit's temporarily 
	var temp_distance : int 
	#we need to save who is the closest human unit 
	var least_distance_unit : Unit
	
	#gathering which human unit has the least amount of distance
	for unit in human_units:
		#doing the manhattan distance calculation
		temp_distance = abs(unit.cell.x - self.cell.x) + abs(unit.cell.y - self.cell.y)
			#since it IS closer, update our record of the shortest distance.
			#least_distance = temp_distance
			#this is the unit the AI will eventually move toward or attack.
			#least_distance_unit = unit
			#by returning null here the gameboard's if near_tile check will faill and ai will stand still when next to a unit
		
		#tank is taunting. 
		#the enemy MUST ignore everyone who isn't a taunting tank.
		if taunter_found:
			if unit.unit_role is Tank and unit.is_taunting:
				#if we are already next to the Tank stop moving
				if temp_distance <= 1:
					return null
				#find the closest taunting tank
				if temp_distance < least_distance:
					least_distance = temp_distance
					least_distance_unit = unit
			else:
				continue

		#no one is taunting Use normal closest human stuff
		else:
			#same as before if already next to unit stop moving
			if temp_distance <= 1:
				return null
			
			if temp_distance < least_distance:
				least_distance = temp_distance
				least_distance_unit = unit
	#
	#print("-----------------------")
	#print(least_distance_unit)
	#print("-----------------------")
	return least_distance_unit
		
		
func check_and_attack_adjacent():
	for unit in gameboard._units.values():
		if unit is BasicEnemy: continue
		
		#calculate distance from our NEW position (self.cell)
		var d = abs(unit.cell.x - self.cell.x) + abs(unit.cell.y - self.cell.y)
		
		if d <= 1:
			gameboard.apply_damage(unit.cell, unit_role.attack_roll(self), self, unit_role.crit)

func _on_container_mouse_entered() -> void:
	health_label.text = "HP: %d" % [current_health]
	$Area2D/Panel.visible = true

func _on_container_mouse_exited() -> void:
	$Area2D/Panel.visible = false
