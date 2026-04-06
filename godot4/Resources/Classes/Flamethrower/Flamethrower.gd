class_name Flamethrower 
extends Unit_Interaction

var Role = "Flamethrower"
#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	print("here")
	attack_range = 3


#think chess king for the attack pattern. I actually have no bloody clue what the attack range is even meant for 
func get_attackable_cells(origin_cell : Vector2, direction : Vector2,caller_name : String):
	attackable_cells.clear()
	#I guess I'll have to do it by hand because I can't see any other way of doing this 
	#left to the origin
	if direction == Vector2(-1,0):
		attackable_cells.append(origin_cell + Vector2(-1,0)) 
		attackable_cells.append(origin_cell + Vector2(-2,0))
		attackable_cells.append(origin_cell + Vector2(-2,1))
		attackable_cells.append(origin_cell + Vector2(-2,-1))

	#Right 
	elif direction == Vector2(1,0):
		attackable_cells.append(origin_cell + Vector2(1,0)) 
		attackable_cells.append(origin_cell + Vector2(2,0))
		attackable_cells.append(origin_cell + Vector2(2,1))
		attackable_cells.append(origin_cell + Vector2(2,-1))	
	#Down
	elif direction == Vector2(0,1):
		attackable_cells.append(origin_cell + Vector2(0,1))
		attackable_cells.append(origin_cell + Vector2(0,2))
		attackable_cells.append(origin_cell + Vector2(-1,2))
		attackable_cells.append(origin_cell + Vector2(1,2))
	
	#up
	elif direction == Vector2(0,-1):
		attackable_cells.append(origin_cell + Vector2(0,-1))
		attackable_cells.append(origin_cell + Vector2(0,-2))
		attackable_cells.append(origin_cell + Vector2(-1,-2))
		attackable_cells.append(origin_cell + Vector2(1,-2))
	else:
		pass

	
	return attackable_cells
#block here for each ability 
func attack():
	print("Musketeer is attacking")

func ability(unit: Unit):
	print("Musketeer is abiltying")

func passive(unit: Unit):
	pass
