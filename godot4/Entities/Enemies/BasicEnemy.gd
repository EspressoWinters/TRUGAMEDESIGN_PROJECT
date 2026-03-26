#This is the basic enemy script, this will be the most basic enemy, the enemy will try to get to the closet player and then attack them
#I will be retrofitting a lot of the unit's script
#keeping the stat system for the enemy, we could then play around and have different enemies with the differing stats 

#this allows us to run it in the editor
@tool
class_name BasicEnemy
#we are extending the unit and now we have access to all the unit's functions and variables 
#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html if you need a reference on inheritance 
extends Unit 


#going to keep an array of all human players, so that we can keep track of those pesky humans 
var human_units := []

#hold the value of the closest unit 
var closest_unit : Unit

#going to go for a hail mary here and just put this code here
#current plan, may get rid of this later, just commenting for myself
#keep _process because that is what is actually moving the character along the path 
#keep _ready as that is just calculating the movement speed and making sure the process is not setting off instantly
#keep walk_along as it is just keeping the curve that the path it will follow


#let's create a function to find the closet player character
func find_closet_human_character():
	
	#error and debugging portion
	if gameboard._units.is_empty():
		print("Roger roger, there are no humans on the board!")
		#exit the function to prevent crash
		return 
		
	#let's get all the units that are human in the array
	for unit in gameboard._units.values():
		if unit is not BasicEnemy:
			human_units.append(unit)
	
	#now we need to calculate the who is the closest 
	#we are using Manhattan distance = | X1 - X2 | + | Y1 - Y2 |, not Eucledian as that would get us errors 
	#our A* algorithm use Manhattan distances for context
	
	#creating variable to hold the distance of the unit
	#just making it a really high number so that it will always "lose" the comparsion
	var least_distance := 1000
	#this is what will be holding the values of the unit's temporarily 
	var temp_distance : int 
	#we need to save who is the closest human unit 
	var least_distance_unit : Unit
	
	#gathering which human unit has the least amount of distance
	for unit in human_units:
		#doing the manhattan distance calculation
		temp_distance = abs(unit.cell.x - self.cell.x) + abs(unit.cell.y - self.cell.y)
		if temp_distance < least_distance:
			least_distance_unit = unit 
			least_distance = temp_distance
	
	print("-----------------------")
	print(least_distance_unit)
	print("-----------------------")
	return least_distance_unit
