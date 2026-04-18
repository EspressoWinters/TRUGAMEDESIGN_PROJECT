#Basic resource class for the enemy 

class_name Basic_enemy 
extends Unit_Interaction

#this resource is here to not cause problems in the game :

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

func attack():
	pass
#
func ability(unit: Unit):
	pass
#
func passive(unit: Unit):
	pass
