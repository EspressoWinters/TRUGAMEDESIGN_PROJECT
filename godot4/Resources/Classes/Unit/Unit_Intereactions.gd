#going to move the resource file to a parent file
class_name Unit_Interaction
extends Resource

@export var skin = Texture2D

var attack_range: int = 1

#holding the cells that are possibly attackable for the overlay
var attackable_cells : Array = []

#holding the cells in the direction of the attack 
var direction_attack_cells : Array = []


#this is just going to be for the attack overlay
func get_attackable_cells(origin_cell : Vector2):
	print("Getting the attack cells")
	return attackable_cells

#this will find just the attackable cells in the direciton that the player is picking g
func get_attackable_cells_direction(origin_cell : Vector2, target_cell : Vector2):
	direction_attack_cells.clear()
	if attackable_cells.is_empty():
		print("Error, the attackable cells are empty!!!!")
		return direction_attack_cells
	#gathering the difference between the two cells 
	var difference = target_cell - origin_cell
	
	var tempDifference
	
	#now get the sign of the differences (1,0,-1), it doesn't matter how much the difference is, just that we know what the sign is with the coordinates 
	difference.sign()
	#now it should be converted into either 1,0,-1
	
	#now we just do the possible cases here
	
	#this needs to definetly be shorten up a bit 
	
	#first case, the upper direction 
	if difference.x == 0 and difference.y == 1:
		#loop through the attackable cell
		for cell in attackable_cells:
			tempDifference = cell - origin_cell
			tempDifference.sign()
			#must mean it was above the coodinates
			#for example (3,5)"cell" - (1,1)"origin" would equal 1 since it is taller
			if ((tempDifference.y) == 1): 
				#this cell must be above it
				direction_attack_cells.append(cell)
		
		for cell in direction_attack_cells:
			print(cell)
				
			
				
		return direction_attack_cells
	#below case 
	elif difference.x == 0 and difference.y == -1:
		#loop through attackable cells again
		for cell in attackable_cells:
			tempDifference = cell - origin_cell
			tempDifference.sign()
			#this means it must be below it
			if ((tempDifference.y) == (-1)):
				direction_attack_cells.append(cell)
				
		for cell in direction_attack_cells:
			print(cell)
		return direction_attack_cells
	#right case 
	elif difference.x == 1 and difference.y == 0:
		for cell in attackable_cells:
			tempDifference = cell - origin_cell
			tempDifference.sign()
			#slide to the right cha cha real smooth 
			if (tempDifference.x == 1):
				direction_attack_cells.append(cell)
				
		for cell in direction_attack_cells:
			print(cell)
			
		return direction_attack_cells
	elif difference.x == -1 and difference.y == 0:
		for cell in attackable_cells:
			tempDifference = cell - origin_cell
			tempDifference.sign()
			if (tempDifference.x == -1):
				direction_attack_cells.append(cell)
				
		for cell in direction_attack_cells:
			print(cell)
			
		return direction_attack_cells
	#okay now the more complicated and probably more common diagonal cases 
	#upper right corner case 
	elif difference.x == 1 and difference.y == 1: 
		for cell in attackable_cells:
			tempDifference = cell - origin_cell
			tempDifference.sign()
			
		for cell in direction_attack_cells:
			print(cell)
		pass 
	

func attack():
	print("Unit is attacking")
	print("This is a debugging print statement, if see in game then error")

func ability():
	print("Unit is abiltying")
	print("This is a debugging print statement, if see in game then error")


func passive():
	pass


func attack_roll(attacker : Unit) -> int:
	print("AATKATKAKKDSVKzs!!")
	return 0

 
