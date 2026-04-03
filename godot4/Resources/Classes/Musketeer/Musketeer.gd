class_name Musketeer 
extends Unit_Interaction


#because for some reason in Godot you can't just access parent variables, therefroe 
func init():
	attack_range = 3

#think chess king for the attack pattern. I actually have no bloody clue what the attack range is even meant for 
func get_attackable_cells(origin_cell : Vector2):
	pass

#block here for each ability 
func attack():
	print("Musketeer is attacking")

func ability():
	print("Musketeer is abiltying")

func passive():
	pass
