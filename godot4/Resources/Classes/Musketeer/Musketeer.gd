#Should be the main burst dps of the game, does a lot of damage 

class_name Musketeer 
extends Unit_Interaction

var ability_luck: float = 0
var luck_charges: int = 0
#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	attack_range = 3


func get_attackable_cells(origin_cell : Vector2, caller_name : String, direction : Vector2):
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

func attack_roll(attacker : Unit) -> int:
	self.crit = false
	var die1 = randi_range(1, 6)
	var die2 = randi_range(1, 6)
	var crit_roll = randf_range(0.0,100.0) #using float for percentage
	
	var marksmen_luck = luck + 5 + ability_luck
	
	var total_damage: int
	#accesses the modifier from the attacker's unit_role
	var modifier = attacker.unit_role.attack_stat
	if crit_roll <= marksmen_luck:
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
	print("Musketeer is attacking")

func ability(unit: Unit):
	if luck_charges > 0 and not has_ablilitied:
		ability_luck = 100
		luck_charges -= 1
		unit.crit_buff.visible = true
		GameConsole.log_message("COMBAT","Musket is lucky. Has %d charges left" % luck_charges)
		has_ablilitied = true
	else:
		GameConsole.log_message("ERROR","No Musket charges left!")

func passive(unit: Unit):
	pass
