#Special Thanks to this Repository for helping build the basis of the movement system of our game. 
#https://github.com/gdquest-demos/godot-2d-tactical-rpg-movement/tree/main/godot4 
#Special thanks to this as well to help explain the code 
#https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/lessons/01.grid/

## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
@export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _walkable_cells := []
var _attackable_cells := []
var _directional_attack_cells := []
var _cell_of_active_unit : Vector2
@onready var tile_map = %Map
@onready var _unit_overlay: UnitOverlay = %UnitOverlay
@onready var _attack_overlay: AttackOverlay = %AttackOverlay
@onready var _unit_path: UnitPath = %UnitPath
@onready var ui = %Ui

var initiative_order := []

var turn_count := 0
var round_count := 0

var _has_moved_this_turn := false
#boolean value on whether it has been attacked
var _has_attacked_this_turn := false
var _move_overlay_visable := false
#having the attack overlay
var _attack_overlay_visable := false

#when the gameboard is called into the scene it will clear its dicitonary of units then fill it up again with the units in tjhe active scenee
func _ready() -> void:
	_reinitialize()
	
	#gatherin the UI attack and such
	if ui:
		ui.move_requested.connect(display_move_overlay)
		ui.attack_requested.connect(clear_overlay)
		ui.attack_requested.connect(display_attack_overlay)
		ui.end_turn_requested.connect(end_turn)
	else:
		push_error("GameBoard: UI node not found at path!")
	
	turn_manager()

func turn_manager():
	roll_initiative()
	start_turn()

##This function will roll the initiative rolls to start the combat
func roll_initiative():
	initiative_order.clear()
	
	for unit in _units.values():
		# this is a dnd style initiative roll with a d20 equivalent
		var initiative_unit_roll :int = (randi_range(0,20)) + unit.unit_info.speed
		unit.initiative_stat = initiative_unit_roll
		initiative_order.append(unit)
	initiative_bubble_sort(initiative_order)

##This will start the turn of the individual unit
func start_turn():
	#set the boolean value to false so it hasn't attacked
	_has_attacked_this_turn = false
	_move_overlay_visable = false
	_has_moved_this_turn = false #Reset the flag for the new unit
	_cell_of_active_unit = _units.find_key(initiative_order[turn_count])
	#print(_cell_of_active_unit, "\n", _units.get(_cell_of_active_unit))
	_select_unit(_cell_of_active_unit)
	print("It is now " + _active_unit.name + "'s turn.")
	print(_active_unit.cell)
	
	#doing AI Logic here
	if _active_unit is BasicEnemy:
		var near_tile
		#get the closest tile from the human
		near_tile = closest_tile_to_human_unit(_active_unit)
		#just making another check to ensure that near_tile exists
		#just printing it to see the tile
		#print(near_tile)
		if near_tile:
			#moving the unit near the tile 
			_move_active_unit(near_tile)
			end_turn()
		else: 
			end_turn()
			print("I'm already as close as can be!")

##This will end the turn of the individual unit, it will also check at the end whether to start a new round or not
func end_turn():
	_deselect_active_unit()
	clear_overlay()
	
	turn_count += 1
	
	# Reset if we hit the end of the list
	if turn_count >= initiative_order.size():
		turn_count = 0
		round_count += 1
		print("--- Round " + str(round_count) + " Over ---")
	_has_moved_this_turn = false
	start_turn()

##This is a simple bubble sort becuase we need to sort initiative
#If you don't know bubble sort here is the algorithm: https://www.geeksforgeeks.org/dsa/bubble-sort-algorithm/
func initiative_bubble_sort(initiative_array: Array):
	for i in range(len(initiative_array)):
		for j in range(len(initiative_array)-1-i):
			if (initiative_array[j].initiative_stat < initiative_array[j+1].initiative_stat):
				swap(initiative_array, j, j+1)
			
	print(initiative_array)

##Godot doesn't have a swap function so we decided to create our own just in case we ever need to swap again,
func swap(initiative_array: Array, i : int, j : int):
	var a = initiative_array[i]
	var b = initiative_array[j]
	var tempValue = a
	a = b
	b = tempValue
	initiative_array[i]=a
	initiative_array[j]=b
	#Just debugging
	print ("A:",a, "\nB:",b)
#General input handler, only for deselecting here
#func _unhandled_input(event: InputEvent) -> void:
	#deselects the current unit when 'ui_cancel' hit if one is selected
	#if _active_unit and event.is_action_pressed("ui_cancel"):
	#	_deselect_active_unit()
	#	_clear_active_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	#has checks if a key matches the given cell in the dictionary
	if _units.has(cell):
		return true
	#Looks at layer 0 at these specific coordinates (cell)
	#takes the id of the cell in the tilemap(rock,grass,water)
	var tile_data: TileData = tile_map.get_cell_tile_data(0,cell)
	if tile_data: #if tile is found
		#Returns the ooposite of "walkable"
		#if  walkable is false, we return true, meaning yes, it is blocked
		return not tile_data.get_custom_data("walkable")
	
	return true


## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)

#use the flood_fill to get the attack range
#instead of flood fill just get the unit.unit_role
func get_attack_range(unit: Unit) -> Array:
	return unit.unit_role.get_attackable_cells(unit.cell)

## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()
	
	#okay passes a reference to the gameboard here so the enemy unit can use it, maybe I could just pass it to just enemies but for ease of use I am just giving it to all units 

	for child in get_children():
		#Checks all children of the gameboard and puts them into the dictionary with their cell as the key if they are a unit and skips it igf its not
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
		#passing the gameboard onto the unit
		unit.gameboard = self 


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	#creates an empty array that will get filled with the cells that are valid
	var array := []
	#Creates the cells to check from and starts with the cell it is given
	var stack := [cell]
	#Checks each cell its given to see if its valid
	while not stack.size() == 0:
		#puts first cell out of stack and keeps it as temp var
		var current = stack.pop_back()
		#checks if the cell is in bounds
		if not grid.is_within_bounds(current):
			continue
		#Checks if already checked and good to go
		if current in array:
			continue
		#calculates the distance from the starting cell and checks if its too far away
		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue
		#adds the validated cell to the array of valid cells
		array.append(current)
		#Adds all the cells around the current cell to the stack to check
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			#checks to see if these cells have already been checked or are quede for checking
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue
			# Minor optimization: If this neighbor is already queued
			#	to be checked, we don't need to queue it again
			if coordinates in stack:
				continue
			#adds valid squares to check to the stack
			stack.append(coordinates)
	return array

#this is the HUMAN/PLAYER Unit movement section
## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	
	var near_tile
	
	var old_cell
	
	#terrible coding standards but we ball
	
	var ai_path
	if _has_moved_this_turn: 
		return
	
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	#okay I am going to add human logic and ai logic, since the AI needs to not get the current path from the cursor and instead calculate itself
	if _active_unit is not BasicEnemy: 
		# warning-ignore:return_value_discarded
		_units.erase(_active_unit.cell)
		_units[new_cell] = _active_unit
		_active_unit.walk_along(_unit_path.current_path)
		#await _active_unit.walk_finished
		#_clear_active_unit()
	#the AI logic
	else: 
		old_cell = _active_unit.cell
		_units.erase(old_cell)
		_units[new_cell] = _active_unit
		near_tile = closest_tile_to_human_unit(_active_unit)
		ai_path = _unit_path._pathfinder.calculate_point_path(_active_unit.cell, near_tile)
		_active_unit.walk_along(ai_path)
		#await _active_unit.walk_finished
		_active_unit.cell = new_cell 
		#_units[near_tile] = _active_unit
	
	#locks players and AI to only move once per turn
	_has_moved_this_turn = true





#this block is going to be where we attack the cells
#just basically see if any of the units get looked up in the unit dictionary and then any unit it can find they will then take damage from i 
func attack_cell(attacked_cells : Array):
	pass

## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	#pre-calulate walkable cells but don't draw them yet
	_walkable_cells = get_walkable_cells(_active_unit)
	#getting the attack range
	_attackable_cells = get_attack_range(_active_unit)
	_unit_path.initialize(_walkable_cells)

#this is the bot/computer movement section 
func closest_tile_to_human_unit(enemy_unit : BasicEnemy):
	var closet_human_unit = enemy_unit.find_closet_human_character()
	if closet_human_unit == null:
		print("There isn't any humans roger roger!")
		return
	
	#now we get all the walkable cells from our trusted flood fill function
	var reachable_cells = _flood_fill(enemy_unit.cell, enemy_unit.move_range)
	
	var closest_tile : Vector2
	#again just a big value for the comparison 
	var least_distance := 1000
	for cell in reachable_cells:
		
		#just adding a check 
		if cell == closet_human_unit.cell:
			continue 
		#adding another check
		if !is_occupied(cell):
			var distance_to_target = abs(cell.x - closet_human_unit.cell.x) + abs(cell.y - closet_human_unit.cell.y)
			if distance_to_target < least_distance:
				least_distance = distance_to_target
				closest_tile = cell 
	#now we should know the closet tile and what it coordinates are, granted with the simple implementation it probably ranadomly picks the tile now but that is fine for the current implementaion 
	return closest_tile
	
	 

func display_move_overlay() -> void:
	if _has_moved_this_turn:
		print("Unit has already moved!")
		return
	
	if _active_unit and _active_unit is not BasicEnemy:
		# Clear any existing overlay first to prevent stacking
		_unit_overlay.clear() 
		_unit_overlay.draw(_walkable_cells)
		# Note: You might want to make the unit_path visible here too
		_unit_path.initialize(_walkable_cells)
		_move_overlay_visable = true
		#get rid of the attack overlay if the movement overlay 
		_attack_overlay_visable = false

#using the attack overlay here 
func display_attack_overlay() -> void:
	if not _has_attacked_this_turn:
		if not _active_unit:
			return

		#cells we want
		var filtered_cells : Array = []
		
		#Defines the bad coordinates (the corners)
		var corners = [
			_active_unit.cell + Vector2(-1, 1),  # Top Left
			_active_unit.cell + Vector2(1, 1),   # Top Right
			_active_unit.cell + Vector2(-1, -1), # Bottom Left
			_active_unit.cell + Vector2(1, -1)   # Bottom Right
		]
		
		#goes through the attackable_cells array and filters the cells to get rid of the corners
		for cell in _attackable_cells:
			#only skips the corners if the unit_role is a tank
			if _active_unit.unit_role is tank:
				if cell in corners:
					continue # Skip this cell, don't add it to filtered_cells
					
			# If we got here, it's a valid cell to draw!
			filtered_cells.append(cell)

		# 4. Draw the filtered list
		if _active_unit:
			_unit_overlay.clear()
			_unit_overlay.draw(filtered_cells)
			_move_overlay_visable = false
			_attack_overlay_visable = true
	else:
		print("Unit has already attacked!")

func clear_overlay() -> void:
	_unit_overlay.clear()    #clears the movement (blue) tiles
	_unit_path.stop()        #clears the movement path line
	
	if _attack_overlay:
		_attack_overlay.clear() #clears the attack (red) tiles
	#resets the bools
	_move_overlay_visable = false
	_attack_overlay_visable = false

## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()


## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	var direction_attack
	
	var damage
	
	#okay so this is if it is visible then do the move overlay here
	if _move_overlay_visable:
		_move_active_unit(cell)
		clear_overlay()
		_attackable_cells = get_attack_range(_active_unit)
	#now we are going to do the attack block
	#NOTES FOR SELF 
	#okay if we have the cell which the player has clicked, then we could get the direction through the sign. 
	#that way we could do direction
	elif _attack_overlay_visable:
		if _has_attacked_this_turn: 
			print("You have already attacked")
	
		#getting all of what we should attack
		direction_attack = _active_unit.unit_role.get_attackable_cells_direction(_active_unit.cell, cell)
		if direction_attack and _has_attacked_this_turn == false:	
			for direction_cell in direction_attack:
				if _units.has(direction_cell):
					apply_damage(direction_cell, _active_unit.unit_role.attack_roll(_active_unit))
			_has_attacked_this_turn = true
			clear_overlay()
	 
	
	#old block of previous implementation
# Only allow movement if the blue tiles are actually showing
	#if _unit_overlay.get_used_cells(0).size() > 0:
		#_move_active_unit(cell)
		#clear_overlay() # Hide tiles after moving
		#_attackable_cells = get_attack_range(_active_unit)
		
	
## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	## Only draw the path line if the move overlay is active
	#if _active_unit and _active_unit.is_selected and _move_overlay_visable == true and _unit_overlay.get_used_cells(0).size() > 0 and _active_unit is not BasicEnemy:
		#_unit_path.draw(_active_unit.cell, new_cell)
	
		if _move_overlay_visable:
			_unit_path.draw(_active_unit.cell, new_cell)
			
		if _attack_overlay_visable == true and _has_attacked_this_turn == false:
			#Ask the unit role for the specific directional cells
			var highlighted_attack_cells = _active_unit.unit_role.get_attackable_cells_direction(_active_unit.cell, new_cell)
			
		#Draw the result on the specific AttackOverlay
		#If cleave_cells is empty (diagonal), .draw() will clear the tiles
			if _attack_overlay:
				_attack_overlay.draw(highlighted_attack_cells)

##This is the function where the unit will take damage 
func damage_unit(unit : Unit, damage : int):
	unit.unit_info.health - damage

#a block here for calling the unit attack, ability, and passive ability, unit attack and ability that she doesn't 
func unit_attack():
	#Check if the variable actually holds an object
	if _active_unit != null:
		display_attack_overlay() 
	else:
		push_warning("No active unit to attack!")

func unit_ability():
	if _active_unit != null:
		_active_unit.unit_role.ability()
	else:
		push_warning("Attempted to ability, but _active_unit is null!")

func unit_passive():
	if _active_unit != null:
		_active_unit.unit_role.passive()
	else:
		push_warning("Attempted to passive, but _active_unit is null!")

func apply_damage(target_cell: Vector2, amount: int) -> void:
	var victim = _units[target_cell]
	victim.current_health -= amount
	print("%s took %d damage!" % [victim.name, amount])
	
	if victim.current_health <= 0:
		_handle_unit_death(target_cell)

func _handle_unit_death(cell: Vector2) -> void:
	var unit_to_remove = _units[cell]
	_units.erase(cell)
	initiative_order.erase(unit_to_remove)
	unit_to_remove.queue_free()
