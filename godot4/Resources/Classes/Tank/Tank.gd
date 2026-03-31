class_name tank
#now we are extending 
extends Unit_Interaction

#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	attack_range = 3

#think chess king for the attack pattern. I actually have no bloody clue what the attack range is even meant for
#maybe here this could be for the overlay and another one handles the users choice 
func get_attackable_cells(origin_cell : Vector2):
	#just clearing it so it didn't save from last time
	attackable_cells.clear()
	#I guess I'll have to do it by hand because I can't see any other way of doing this 
	#left to the origin
	attackable_cells.append(origin_cell + Vector2(-1,0)) 
	#above the origin 
	attackable_cells.append(origin_cell + Vector2(0,1))
	#right to the origin 
	attackable_cells.append(origin_cell + Vector2(1,0))
	#below the origin
	attackable_cells.append(origin_cell + Vector2(0,-1)) 
	
	#Getting rid of the corners
	#diagonally to the top left of the unit
	#attackable_cells.append(origin_cell + Vector2(-1,1))
	#diagonally to the bottom left of the unit 
	#attackable_cells.append(origin_cell + Vector2(-1,-1))
	#digonally to the top right of the unit 
	#attackable_cells.append(origin_cell + Vector2(1,1))
	#digonally to the bottom left of the unit
	#attackable_cells.append(origin_cell + Vector2(1,-1))
	
	return attackable_cells

#basically we only want to get cells in the direction of the attack itself 
#instead maybe I should put it into the parent class because it not like the direction changeing ever because of the unit 
#static func get_attackable_cells_direction(origin_cell : Vector2, target_cell : Vector2):
	#pass 

func attack_roll(attacker : Unit) -> int:
	var die1 = randi_range(1, 6)
	var die2 = randi_range(1, 6)
	
	#accesses the modifier from the attacker's unit_info
	var modifier = attacker.unit_info.attack
	var total_damage = die1 + die2 + modifier
	
	print(total_damage)
	
	return total_damage
	
#block here for each ability 
func attack():
	print("Tank is attacking")

func ability():
	print("Tank is abiltying")

func passive():
	pass


 
