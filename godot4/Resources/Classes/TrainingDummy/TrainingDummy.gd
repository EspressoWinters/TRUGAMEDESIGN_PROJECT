class_name TrainingDummy_class
#now we are extending 
extends Unit_Interaction
var Role = "Training Dummy"

var taunt_charges : int = 0

#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	attack_range = 3

#think chess king for the attack pattern. I actually have no bloody clue what the attack range is even meant for
#maybe here this could be for the overlay and another one handles the users choice 
func get_attackable_cells(origin_cell : Vector2, caller_name : String, direction : Vector2):
	#just clearing it so it didn't save from last time
	attackable_cells.clear()

	return attackable_cells

#basically we only want to get cells in the direction of the attack itself 
#instead maybe I should put it into the parent class because it not like the direction changeing ever because of the unit 
#static func get_attackable_cells_direction(origin_cell : Vector2, target_cell : Vector2):
	#pass 

func attack_roll(attacker : Unit) -> int:
	return 0
	
	
#block here for each ability 
func attack():
	print("")

func ability(unit: Unit):
	print("")

func passive(unit: Unit):
	pass

 
