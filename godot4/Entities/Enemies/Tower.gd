#this tower class will be doing minimum damage and then also doing an all around lower attack 
#should keep the damage low 

@tool
class_name Tower

extends Unit 


#going to keep an array of all human players, so that we can keep track of those pesky humans 
var human_units := []
var tank_units := []
#hold the value of the closest unit 
var closest_unit : Unit
var taunter_found := false

#it probably needs some attackable cells, like the unit  
var attackable_human_cells : Array = []

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
