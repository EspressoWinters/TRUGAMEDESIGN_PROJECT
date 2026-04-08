class_name Flamethrower 
extends Unit_Interaction


#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	print("here")
	attack_range = 3


#think chess king for the attack pattern. I actually have no bloody clue what the attack range is even meant for 
func get_attackable_cells(origin_cell : Vector2, caller_name : String, direction : Vector2):
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

#block here for each ability 
func attack():
	print("Musketeer is attacking")

func ability(unit: Unit):
	explodering = true
	print("Musketeer is abiltying")
	

func passive(unit: Unit):
	pass
