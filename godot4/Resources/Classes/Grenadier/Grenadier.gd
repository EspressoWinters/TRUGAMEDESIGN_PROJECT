class_name Grenadier 
extends Unit_Interaction

var Role = "Grenadier"


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
func get_attackable_cells(origin_cell : Vector2, direction : Vector2 = Vector2.ZERO):
	var cell
	#clear it, probably because we don't need it now because we have the origin piece
	attackable_cells.clear()
	
	for x in range(-1,2):
		for y in range(-1,2):
			cell = origin_cell + Vector2(x,y)
			
			if cell not in attackable_cells:
				attackable_cells.append(cell)
			
			
	
	return attackable_cells 
	
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
