class_name tank
extends Resource

@export var skin = Texture2D

@export var attack_range: int = 1

##We pass the GameBoard so the resource can call 'apply_damage'
func attack(attacker: Unit, target_cell: Vector2, board: GameBoard):
	var die1 = randi_range(1, 6)
	var die2 = randi_range(1, 6)
	
	#accesses the modifier from the attacker's unit_info
	var modifier = attacker.unit_info.attack
	var total_damage = die1 + die2 + modifier
	
	print("Tank Attack: (%d + %d) + %d mod = %d total" % [die1, die2, modifier, total_damage])
	
	#tells the board to actually subtract the HP
	board.apply_damage(target_cell, total_damage)

func ability():
	print("Tank is abiltying")

func passive():
	pass
