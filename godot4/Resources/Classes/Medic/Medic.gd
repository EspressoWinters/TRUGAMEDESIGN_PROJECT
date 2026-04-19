#this medic class will not be able to attack and damage but rather be the only unit in the game able to heal itself and others 

class_name Medic
#now we are extending 
extends Unit_Interaction
var Role = "Medic"

var has_global_healed = false


func get_attackable_cells(origin_cell : Vector2, caller_name : String, direction : Vector2):
	#just clearing it so it didn't save from last time
	attackable_cells.clear()
	#I guess I'll have to do it by hand because I can't see any other way of doing this 
	#lef	attackable_cells.clear()
	#I guess I'll have to do it by hand because I can't see any other way of doing this 
	#left to the origin
	
	if caller_name == "passive":
		attackable_cells.append(origin_cell + Vector2(-1,0))
		attackable_cells.append(origin_cell + Vector2(1,0))
		attackable_cells.append(origin_cell + Vector2(0,1))
		attackable_cells.append(origin_cell + Vector2(0,-1))
		attackable_cells.append(origin_cell + Vector2(0,0))
		attackable_cells.append(origin_cell + Vector2(-1,1))
		attackable_cells.append(origin_cell + Vector2(-1,-1))
		attackable_cells.append(origin_cell + Vector2(1,1))
		attackable_cells.append(origin_cell + Vector2(1,-1))
	
	elif direction == Vector2(-1,0):
		attackable_cells.append(origin_cell + Vector2(-1,0)) 

	#Right 
	elif direction == Vector2(1,0):
		attackable_cells.append(origin_cell + Vector2(1,0)) 

	#Down
	elif direction == Vector2(0,1):
		attackable_cells.append(origin_cell + Vector2(0,1))
	
	#up
	elif direction == Vector2(0,-1):
		attackable_cells.append(origin_cell + Vector2(0,-1))

	else:
		pass
	return attackable_cells

#basically we only want to get cells in the direction of the attack itself 
#instead maybe I should put it into the parent class because it not like the direction changeing ever because of the unit 
#static func get_attackable_cells_direction(origin_cell : Vector2, target_cell : Vector2):
	#pass 

func attack_roll(attacker : Unit) -> int:
	var die1 = randi_range(10, 20)
	var crit = randf_range(0.0,100.0) #using float for percentage
	
	
	var total_damage: int
	#accesses the modifier from the attacker's unit_role
	var modifier = attacker.unit_role.attack_stat
	if crit <= luck:
		var crit_multiplier = 2.0
		print("CRITICAL HIT!")
		total_damage = (((die1 + modifier) * crit_multiplier) * -1)
		crit = true
	else:
		total_damage = ((die1 + modifier) * -1)
		crit = false
	print(total_damage)
	
	return total_damage
	
#block here for each ability 
func attack():
	pass

func ability(unit: Unit):
#get everyone in the "units" group
	var all_potential_targets = unit.get_tree().get_nodes_in_group("player_units")
	
	if has_global_healed == false:
		for target in all_potential_targets:
			#check if the target is NOT a BasicEnemy
			has_global_healed = true
			if not (target is BasicEnemy) and target.has_method("heal"):
				VfxManager.play_vfx("heal_attack", target.global_position)
				DamageNumbers.display_number(-20, target.global_position, false)
				target.heal(20) #heal amount
				GameConsole.log_message("COMBAT", "Healed ally: %s" % target.name)
			else:
				print("Skipped healing: ", target.name, " (Enemy or invalid or has already global healed)")
	else:
		GameConsole.log_message("ERROR","Has already global healed this battle")
func passive(unit: Unit):
	var healing_aoe_cells = get_attackable_cells(unit.cell, "passive", Vector2(0,0))
	return healing_aoe_cells
