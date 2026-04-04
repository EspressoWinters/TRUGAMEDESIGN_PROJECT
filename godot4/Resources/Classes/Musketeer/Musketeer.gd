class_name Musketeer 
extends Unit_Interaction


#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	attack_range = 3

#think chess king for the attack pattern. I actually have no bloody clue what the attack range is even meant for 
func get_attackable_cells(origin_cell : Vector2, direction : Vector2):
	attackable_cells.clear()
	#I guess I'll have to do it by hand because I can't see any other way of doing this 
	#left to the origin
	if direction == Vector2(-1,0):
		attackable_cells.append(origin_cell + Vector2(-2,0)) 
		attackable_cells.append(origin_cell + Vector2(-3,0))
		attackable_cells.append(origin_cell + Vector2(-4,0))
		attackable_cells.append(origin_cell + Vector2(-5,0))

	#Right 
	elif direction == Vector2(1,0):
		attackable_cells.append(origin_cell + Vector2(2,0)) 
		attackable_cells.append(origin_cell + Vector2(3,0))
		attackable_cells.append(origin_cell + Vector2(4,0))
		attackable_cells.append(origin_cell + Vector2(5,0))	
	#Down
	elif direction == Vector2(0,1):
		attackable_cells.append(origin_cell + Vector2(0,2))
		attackable_cells.append(origin_cell + Vector2(0,3))
		attackable_cells.append(origin_cell + Vector2(0,4))
		attackable_cells.append(origin_cell + Vector2(0,5))
	
	#up
	elif direction == Vector2(0,-1):
		attackable_cells.append(origin_cell + Vector2(0,-2))
		attackable_cells.append(origin_cell + Vector2(0,-3))
		attackable_cells.append(origin_cell + Vector2(0,-4))
		attackable_cells.append(origin_cell + Vector2(0,-5))
	else:
		pass

	
	return attackable_cells
#block here for each ability 
func attack():
	print("Musketeer is attacking")

func ability():
	print("Musketeer is abiltying")

func passive(unit: Unit):
	pass
