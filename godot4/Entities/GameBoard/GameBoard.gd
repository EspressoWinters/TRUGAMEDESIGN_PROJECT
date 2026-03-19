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
var _cell_of_active_unit : Vector2
@onready var tile_map = $"../Map"
@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath
@onready var ui = $"../Ui"

var initiative_order := []

var turn_count := 0
var round_count := 0

var _has_moved_this_turn := false

#when the gameboard is called into the scene it will clear its dicitonary of units then fill it up again with the units in tjhe active scenee
func _ready() -> void:
	_reinitialize()
	
	if ui:
		ui.move_requested.connect(display_move_overlay)
		ui.attack_requested.connect(clear_overlay)
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
		var initiative_unit_roll :int = (randi_range(0,20)) + unit.speed
		unit.initiative_stat = initiative_unit_roll
		initiative_order.append(unit)
	initiative_bubble_sort(initiative_order)

##This will start the turn of the individual unit
func start_turn():
	_has_moved_this_turn = false #Reset the flag for the new unit
	_cell_of_active_unit = _units.find_key(initiative_order[turn_count])
	#print(_cell_of_active_unit, "\n", _units.get(_cell_of_active_unit))
	_select_unit(_cell_of_active_unit)
	print("It is now " + _active_unit.name + "'s turn.")

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


## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()

	for child in get_children():
		#Checks all children of the gameboard and puts them into the dictionary with their cell as the key if they are a unit and skips it igf its not
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit


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


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if _has_moved_this_turn: return
	
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	_has_moved_this_turn = true #Lock movement for the rest of this turn
	#_clear_active_unit()


## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	#pre-calulate walkable cells but don't draw them yet
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_path.initialize(_walkable_cells)

func display_move_overlay() -> void:
	if _has_moved_this_turn:
		print("Unit has already moved!")
		return
	
	if _active_unit:
		# Clear any existing overlay first to prevent stacking
		_unit_overlay.clear() 
		_unit_overlay.draw(_walkable_cells)
		# Note: You might want to make the unit_path visible here too
		_unit_path.initialize(_walkable_cells)

func clear_overlay() -> void:
	_unit_overlay.clear()
	_unit_path.stop()

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
# Only allow movement if the blue tiles are actually showing
	if _unit_overlay.get_used_cells(0).size() > 0:
		_move_active_unit(cell)
		clear_overlay() # Hide tiles after moving

## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	# Only draw the path line if the move overlay is active
	if _active_unit and _active_unit.is_selected and _unit_overlay.get_used_cells(0).size() > 0:
		_unit_path.draw(_active_unit.cell, new_cell)
