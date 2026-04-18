#this class 

class_name Grenadier 
extends Unit_Interaction


var has_used_speed_boost : bool = false

func init():
	print("here")
	attack_range = 3
	
	

#10 range square
#direction doesn't matter 



#this will get the attack range of the blast 
#is going to be unique to class as the Grenadier is a different type of class compared to the rest
#the origin here is going to be where the cell is
#should return array of attackable cells? 
#this should be used for the argument 
func get_attack_range(origin_cell: Vector2) -> Array:
	
	#should clear the bloody thing 
	attackable_cells.clear()
	
	var cell
	#it should be able to blow itself up 
	attackable_cells.append(origin_cell)
		
		
	#redoing the tank loop in the code doesn't work, so have to do this nested loop
	#the tank loop would keep the center pieces of the code as not fillied
	#so instead this was it will calculate it all and fill it in 
	#https://forum.godotengine.org/t/fundamentals-of-grid-based-games/115931/2
	#got the idea in that link where people wanted to make a square grid 
	#https://forum.godotengine.org/t/a-question-about-for-and-range/20632 for the in range
	#and though the forum isn't directly telling here, in range goes -1 at the second paramter number
	#sorry for this big long text, someone wanted to know how to use this so they could do the tower so just putting it here for them
	for x in range(-5, 6):
		for y in range(-5, 6):
			cell = origin_cell + Vector2(x, y)
			#trying to avoid duplicates because had issue with duplicats 
			if cell not in attackable_cells:
				attackable_cells.append(cell)
		
		
	return attackable_cells 


#this will get their blase radius from the explosion 
#the origin cell here is different compared to the other units, it is actually going to be where the cell is pressed 
#FUCK!!!! KILL ME!!, this is going to be a pain in the ass to do the overlay  ain't it?
func get_attackable_cells(origin_cell : Vector2, caller_name : String, direction : Vector2 = Vector2.ZERO):
	var cell
	#clear it, probably because we don't need it now because we have the origin piece
	attackable_cells.clear()
	
	for x in range(-1,2):
		for y in range(-1,2):
			cell = origin_cell + Vector2(x,y)
			
			if cell not in attackable_cells:
				attackable_cells.append(cell)
			
			
	
	return attackable_cells 

func attack_roll(attacker : Unit) -> int:
	var die1 = randi_range(1, 6)
	var die2 = randi_range(1, 6)
	var crit = randf_range(0.0,100.0) #using float for percentage
	
	
	var total_damage: int
	#accesses the modifier from the attacker's unit_role
	var modifier = attacker.unit_role.attack_stat
	if crit <= luck:
		var crit_multiplier = 2.0
		print("CRITICAL HIT!")
		total_damage = ((die1 + die2 + modifier) * crit_multiplier)
		crit = true
	else:
		crit = false
		total_damage = (die1 + die2 + modifier)
	print(total_damage)
	
	return total_damage

func attack():
	print("Musketeer is attacking")

func ability(unit: Unit):
	
	if has_used_speed_boost == false:
		self.speed *= 2 
		has_used_speed_boost = true  
	else:
		print("You have used your speed boost")
	
func passive(unit: Unit):
	pass
