#Lobotomized enemy

#this allows us to run it in the editor
@tool
class_name TrainingDummy
#we are extending the unit and now we have access to all the unit's functions and variables 
#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html if you need a reference on inheritance 
extends BasicEnemy 


func find_closet_human_character():
	return null

		
func check_and_attack_adjacent():
	print("")
			
