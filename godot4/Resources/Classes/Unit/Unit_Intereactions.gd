#going to hold our stats and such of the units in this resource file

#going to move the resource file to a parent file
class_name Unit_Interaction
extends Resource

@export var skin = Texture2D

@export var ID: int
@export var role: String = ""
@export var max_hp: int = 20
@export var current_health: int
@export var attack_stat: int = 5
@export var speed: int = 5
@export var defense: int = 5 
@export var luck: int = 5
@export var level: int = 1
@export var xp: int = 100
@export var crit: bool = false
@export var atk_explain: String
@export var ability_explain: String
@export var passive_explain: String
var attack_range: int = 1

#holding the cells that are possibly attackable for the overlay
var attackable_cells : Array = []

#holding the cells in the direction of the attack 
var direction_attack_cells : Array = []

var on_fire:bool = false
var turns_left_on_fire: int = 0
var explodering : bool = false
var has_ablilitied: bool = false

#this is just going to be for the attack overlay
func get_attackable_cells(origin_cell : Vector2, caller_name : String, direction : Vector2):
	print("Getting the attack cells")
	return attackable_cells

#this will find just the attackable cells in the direciton that the player is picking g
func get_attackable_cells_direction(origin_cell : Vector2, target_cell : Vector2):
	direction_attack_cells.clear()
	#if attackable_cells.is_empty():
		#print("Error, the attackable cells are empty!!!!")
		#return direction_attack_cells
	#gathering the difference between the two cells 
	var difference = target_cell - origin_cell
	
	#var tempDifference
	
	#now get the sign of the differences (1,0,-1), it doesn't matter how much the difference is, just that we know what the sign is with the coordinates 
	difference.sign()
	#now it should be converted into either 1,0,-1
	#direction_attack_cells.append(difference)
	return difference


#func attack():
	#print("Unit is attacking")
	#print("This is a debugging print statement, if see in game then error")
#
#func ability():
	#print("Unit is abiltying")
	#print("This is a debugging print statement, if see in game then error")
#
#func passive():
	#print("")

func attack_roll(attacker : Unit) -> int:
	print("AATKATKAKKDSVKzs!!")
	#making it four because I want to see if grenade dude passive works 
	return 4
