#Should be well the tank, it shouldn't do much damage but it should be able to take a beating and protect weaker units 


class_name Tank
#now we are extending 
extends Unit_Interaction
var Role = "Tank"

var taunt_charges : int = 0

#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	attack_range = 3

#slashs in 3 spaces in each direciton 
func get_attackable_cells(origin_cell : Vector2, caller_name : String, direction : Vector2):
	#just clearing it so it didn't save from last time
	attackable_cells.clear()
	#I guess I'll have to do it by hand because I can't see any other way of doing this 
	#lef	attackable_cells.clear()
	#I guess I'll have to do it by hand because I can't see any other way of doing this 
	#left to the origin
	if direction == Vector2(-1,0):
		attackable_cells.append(origin_cell + Vector2(-1,0)) 
		attackable_cells.append(origin_cell + Vector2(-1,1))
		attackable_cells.append(origin_cell + Vector2(-1,-1))

	#Right 
	elif direction == Vector2(1,0):
		attackable_cells.append(origin_cell + Vector2(1,0)) 
		attackable_cells.append(origin_cell + Vector2(1,-1))
		attackable_cells.append(origin_cell + Vector2(1,1))

	#Down
	elif direction == Vector2(0,1):
		attackable_cells.append(origin_cell + Vector2(0,1))
		attackable_cells.append(origin_cell + Vector2(-1,1))
		attackable_cells.append(origin_cell + Vector2(1,1))
	
	#up
	elif direction == Vector2(0,-1):
		attackable_cells.append(origin_cell + Vector2(1,-1))
		attackable_cells.append(origin_cell + Vector2(-1,-1))
		attackable_cells.append(origin_cell + Vector2(0,-1))

	else:
		pass
	return attackable_cells

#basically we only want to get cells in the direction of the attack itself 
#instead maybe I should put it into the parent class because it not like the direction changeing ever because of the unit 
#static func get_attackable_cells_direction(origin_cell : Vector2, target_cell : Vector2):
	#pass 

func attack_roll(attacker : Unit) -> int:
	self.crit = false
	var die1 = randi_range(1, 6)
	var die2 = randi_range(1, 6)
	var crit_roll = randf_range(0.0,100.0) #using float for percentage
	
	
	var total_damage: int
	#accesses the modifier from the attacker's unit_role
	var modifier = attacker.unit_role.attack_stat
	if crit_roll <= luck:
		var crit_multiplier = 2.0
		print("CRITICAL HIT!")
		total_damage = ((die1 + die2 + modifier) * crit_multiplier)
		self.crit = true
	else:
		total_damage = (die1 + die2 + modifier)
		self.crit = false
	print(total_damage)
	
	return total_damage
	
#block here for each ability 
func attack():
	print("Tank is attacking")

func ability(unit: Unit):
	if taunt_charges > 0 and not has_ablilitied:
		taunt_charges -= 1
		unit.is_taunting = true
		has_ablilitied = true
		unit.taunt_buff.visible = true
		GameConsole.log_message("COMBAT","Tank is making some noise! Charges remaining: %d" % taunt_charges)
	else:
		GameConsole.log_message("ERROR","No taunt charges left!")

func passive(unit: Unit):
	var heal_amount = 5
	current_health += heal_amount
	current_health = clamp(current_health, 0, unit.max_health)
	unit.set_health_bar()
	print("Tank passive healed for 5!")

 
