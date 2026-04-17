#Special Thanks to this Repository for helping build the basis of the movement system of our game. 
#https://github.com/gdquest-demos/godot-2d-tactical-rpg-movement/tree/main/godot4
#----------------------------------------------------------------------------------
#Special thanks to this as well to help explain the code 
#https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/lessons/01.grid/
#----------------------------------------------------------------------------------
#Special tanks to this creator of the font
#https://managore.itch.io/m5x7
## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

signal _update_health_bar
const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
@export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var _units := {}
var _active_unit: Unit
var _walkable_cells := []
var _attackable_cells := []
var _targetable_cells := []
var _cell_of_active_unit : Vector2
var  attack_direction : Vector2
@onready var tile_map = %Map
@onready var _unit_overlay: UnitOverlay = %UnitOverlay
@onready var _attack_overlay: AttackOverlay = %AttackOverlay
@onready var _unit_path: UnitPath = %UnitPath
@onready var ui = %Ui
@onready var timer := $Timer
var initiative_order := []

var turn_count := 0
var round_count := 0

var _has_moved_this_turn := false
#boolean value on whether it has been attacked
var _has_attacked_this_turn := false
var _move_overlay_visable := false
#having the attack overlay
var _attack_overlay_visable := false


#firethrower passive variables 
var fire_dot_damage: int = 2
var fire_dot_turns: int = 5

#signal enemy_done_moving
#grenaider speed boost passive 
var has_done_speed_boost_once := false 

var flame_explosion_damage: int = 15

var boss_tower_healing : int = 5
#when the gameboard is called into the scene it will clear its dicitonary of units then fill it up again with the units in tjhe active scenee
func _ready() -> void:
	_reinitialize()
	#gatherin the UI attack and such
	var current_level = get_tree().current_scene.name
	if current_level == "Level_9_boss":
		SoundManager._play_boss_music()
	
	if ui:
		ui.move_requested.connect(display_move_overlay)
		ui.attack_requested.connect(clear_overlay)
		ui.attack_requested.connect(display_attack_overlay)
		ui.end_turn_requested.connect(end_turn)
		ui.ability_requested.connect(unit_ability)
	else:
		push_error("GameBoard: UI node not found at path!")
	await spawn_party_from_manager()
	turn_manager()

func turn_manager():
	roll_initiative()
	start_turn()

##This function will roll the initiative rolls to start the combat
func roll_initiative():
	initiative_order.clear()
	
	for unit in _units.values():
		# this is a dnd style initiative roll with a d20 equivalent
		var initiative_unit_roll :int = (randi_range(0,20)) + unit.unit_role.speed
		unit.initiative_stat = initiative_unit_roll
		initiative_order.append(unit)
	initiative_bubble_sort(initiative_order)
	print(initiative_order)


##This will start the turn of the individual unit
func start_turn():
	#set the boolean value to false so it hasn't attacked
	_has_attacked_this_turn = false
	_move_overlay_visable = false
	_has_moved_this_turn = false #Reset the flag for the new unit
	_cell_of_active_unit = _units.find_key(initiative_order[turn_count])
	#print(_cell_of_active_unit, "\n", _units.get(_cell_of_active_unit))
	_select_unit(_cell_of_active_unit)
	#only affeects the taunt 
	if _active_unit.is_taunting == true:
		_active_unit.is_taunting = false
		_active_unit.taunt_buff.visible = false
	#resets muskateer ability cooldown
	_active_unit.unit_role.has_ablilitied = false
	#Fire DOT damage
	if _active_unit.unit_role.turns_left_on_fire > 0 and _active_unit.unit_role.on_fire == true:
		apply_damage(_active_unit.cell,fire_dot_damage,null, false)
		_active_unit.unit_role.turns_left_on_fire -= 1
	elif _active_unit.unit_role.turns_left_on_fire == 0 and _active_unit.unit_role.on_fire == true:
		_active_unit.unit_role.on_fire = false
		_active_unit.update_fire_vfx()
	#activates passive at start of turn
	_active_unit.unit_role.passive(_active_unit)
	
	GameConsole.log_message("GAMEMASTER","It is now " + _active_unit.name + "'s turn.")
	print(_active_unit.cell)
		##catches if fire dot kills the enemy it doesnt lock
	if !_active_unit:
		end_turn()
	if _active_unit.unit_role is Tower_Res:
		
		var temp_cell
		var attack_range
		var damage 
		
		var target_unit 
		
		attack_range = _active_unit.get_attack_range(_active_unit.cell)
		
		
		for taunt_cell in attack_range:
			if _units.has(taunt_cell):
				if _units[taunt_cell].is_taunting:
					_active_unit.taunter_found = true 
					temp_cell = taunt_cell
			
		
		if _active_unit.taunter_found:
			damage = _active_unit.unit_role.attack_roll(_active_unit)
			apply_damage(temp_cell, damage, _active_unit, false)
		else:
			for attack_cell in attack_range:
				#skip itself
				if attack_cell == _active_unit.cell:
					continue 
				#create the user here just because want to check
				if _units.has(attack_cell):
					target_unit = _units[attack_cell]
					#add the friendly check so it doesn't do friendly fire
					if target_unit is not BasicEnemy and target_unit is not HunterEnemy and target_unit is not BigEnemy and target_unit is not BossMain and target_unit is not WalkingTrainingDummy and target_unit is not Tower: 
						damage = _active_unit.unit_role.attack_roll(_active_unit)
						apply_damage(attack_cell, damage, _active_unit, false)
		#timer.start()
		#await timer.timeout
		end_turn()
	
	if _active_unit is BossTower:
		for cell in _units:
				var unit_at_cell = _units[cell]
				if unit_at_cell is BossMain:
					_trigger_attack_vfx(cell)
					apply_damage(cell, -boss_tower_healing, _active_unit, false)
				
		end_turn()
	
	if _active_unit.unit_role is Medic:
		for healing_cell in _active_unit.unit_role.passive(_active_unit):
			if _units.has(healing_cell):
				var target_unit = _units[healing_cell]
				
				if target_unit.is_in_group("player_units"):
					_trigger_attack_vfx(healing_cell)
					apply_damage(healing_cell, -1, _active_unit, false)
					print(healing_cell)
	
	#checking at the start of turn to turn off the grenadier speed boost
	if _active_unit.unit_role is Grenadier:
		#need to halve the speed back to base
		if _active_unit.unit_role.has_used_speed_boost == true and has_done_speed_boost_once == false:
			#should be back to the original stat now 
			_active_unit.unit_role.speed /= 2
			_active_unit.recalculate_speed()
			_walkable_cells = get_walkable_cells(_active_unit)
			#now we need to update thy path 
			_unit_path.initialize(_walkable_cells)
			
			if _move_overlay_visable:
				_unit_overlay.clear()
				_unit_overlay.draw(_walkable_cells)
			#need to reset that 
			has_done_speed_boost_once = true 
	
	#doing AI Logic here
	if _active_unit is BasicEnemy or _active_unit is HunterEnemy or _active_unit is BigEnemy or _active_unit is BossMain or _active_unit is WalkingTrainingDummy:
		var near_tile
		#get the closest tile from the human
		near_tile = closest_tile_to_human_unit(_active_unit)
		#just making another check to ensure that near_tile exists
		#just printing it to see the tile
		print(near_tile)
		
		if near_tile:
			#moving the unit near the tile 
			_move_active_unit(near_tile)
			await _active_unit.walk_finished
			#enemy_done_moving.emit()
			_active_unit.check_and_attack_adjacent()
			#timer.start()
			#await timer.timeout
			#end_turn()
		else:
			#await _active_unit.walk_finished
			#enemy_done_moving.emit()
			_active_unit.check_and_attack_adjacent()
			#timer.start()
			#await timer.timeout
		end_turn()
			#print("I'm already as close as can be!")
			

##This will end the turn of the individual unit, it will also check at the end whether to start a new round or not
func end_turn():
	if _active_unit == null:
		ui.combat_end_label_ui.text = "LOSER"
		get_tree().paused = true
		ui.combat_end_ui.visible = true
		ui.continue_button_ui.visible = false
		ui.battle_ui.visible = false
		return
	
	
	#Resets muskateers ability at the end of turn
	if _active_unit.unit_role is Musketeer:
		_active_unit.crit_buff.visible = false
		_active_unit.unit_role.ability_luck = 0
	
	_deselect_active_unit()
	clear_overlay()
	
	turn_count += 1
	
	# Reset if we hit the end of the list
	if turn_count >= initiative_order.size():
		turn_count = 0
		round_count += 1
		GameConsole.log_message("GAMEMASTER","--- Round " + str(round_count) + " Over ---")
	_has_moved_this_turn = false
	await _check_for_victory_or_defeat()
	if not get_tree().paused:
		#call_deferred breaks the recursion loop
		call_deferred("start_turn")
		#called_deferred broke the turns
		#start_turn()

##This is a simple bubble sort becuase we need to sort initiative
#If you don't know bubble sort here is the algorithm: https://woverww.geeksforgeeks.org/dsa/bubble-sort-algorithm/
func initiative_bubble_sort(initiative_array: Array):
	for i in range(len(initiative_array)):
		for j in range(len(initiative_array)-1-i):
			if (initiative_array[j].initiative_stat < initiative_array[j+1].initiative_stat):
				swap(initiative_array, j, j+1)
			
	#print(initiative_array)

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
	#print ("A:",a, "\nB:",b)
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

func is_wall(cell: Vector2) -> bool:
	#has checks if a key matches the given cell in the dictionary
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
func get_targetable_cells(unit: Unit) -> Array:
	var relative_directions := []
	for directions in DIRECTIONS:
		#if not is_wall(unit.cell + directions):
		relative_directions.append(unit.cell + directions)
		#else:
			#continue

	return relative_directions

## Clears, and refills the `_units` dictionary with game objects that are on the board.
func _reinitialize() -> void:
	_units.clear()
	var tank_list = []
	var musketeer_list = []
	for child in get_children():
		var unit := child as Unit
		if not unit: continue
		
		_units[unit.cell] = unit
		unit.gameboard = self 
		#Removed this as it was making all enemies attack when any enemy is done walking
		#if unit is BasicEnemy or unit is HunterEnemy or unit is BigEnemy or _active_unit is BossMain or _active_unit is BossTower:
			#if not enemy_done_moving.is_connected(unit.check_and_attack_adjacent):
				#enemy_done_moving.connect(unit.check_and_attack_adjacent)
		if unit.unit_role is Musketeer:
			musketeer_list.append(unit)
		# Check if the unit's role is a Tank
		if unit.unit_role is Tank:
			tank_list.append(unit)
	# Now assign charges based on the total count found
	var total_muskateers = tank_list.size()
	var total_tanks = tank_list.size()
	for t in tank_list:
		# Example: Each tank gets 1 charge for every tank present
		t.unit_role.taunt_charges = total_tanks
		print("Tank %s initialized with %d charges." % [t.name, total_tanks])
	for m in musketeer_list:
		m.unit_role.luck_charges = total_muskateers
		print("Musketeer %s initialized with %d charges." % [m.name, total_muskateers])

	
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

	var ai_path
	if _has_moved_this_turn: 
		return
	
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	#okay I am going to add human logic and ai logic, since the AI needs to not get the current path from the cursor and instead calculate itself
	if _active_unit is not BasicEnemy and _active_unit is not HunterEnemy and _active_unit is not BigEnemy and _active_unit is not BossMain and _active_unit is not BossTower: 
		
		ui.can_next_turn = false 
		# warning-ignore:return_value_discarded
		_units.erase(_active_unit.cell)
		_units[new_cell] = _active_unit
		_active_unit.walk_along(_unit_path.current_path)
		await _active_unit.walk_finished
		ui.can_next_turn = true
		#_clear_active_unit()
	#the AI logic
	else: 
		#adding protection 
		ui.can_next_turn = false 
		_units.erase(_active_unit.cell)
		_units[new_cell] = _active_unit
		ai_path = _unit_path._pathfinder.calculate_point_path(_active_unit.cell, new_cell)
		_active_unit.walk_along(ai_path)
		#await _active_unit.walk_finished
		_active_unit.cell = new_cell 
		await _active_unit.walk_finished
		#now players can press it.
		ui.can_next_turn = true
		#_units[near_tile] = _active_unit
	
	#locks players and AI to only move once per turn
	_has_moved_this_turn = true


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
	_targetable_cells = get_targetable_cells(_active_unit)
	_unit_path.initialize(_walkable_cells)

#this is the bot/computer movement section 
func closest_tile_to_human_unit(enemy_unit : Variant):
	var closet_human_unit = enemy_unit.find_closet_human_character()
	#print(closet_human_unit)
	if closet_human_unit == null:
		#print("There isn't any humans roger roger!")
		return
	
	#now we get all the walkable cells from our trusted flood fill function
	var reachable_cells = _flood_fill(enemy_unit.cell, enemy_unit.move_range)
	
	var closest_tile : Vector2
	#again just a big value for the comparison 
	var least_distance := 1000
	for cell in reachable_cells:
		if is_occupied(cell):
			pass
		#just adding a check 
		if cell == closet_human_unit.cell:
			pass 
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
		GameConsole.log_message("ERROR","Unit has already moved!")
		return
	
	if _active_unit and _active_unit is not BasicEnemy and _active_unit is not HunterEnemy and _active_unit is not BigEnemy  and _active_unit is not BossMain and _active_unit is not BossTower: 
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
		#var corners = [
			#_active_unit.cell + Vector2(-1, 1),  # Top Left
			#_active_unit.cell + Vector2(1, 1),   # Top Right
			#_active_unit.cell + Vector2(-1, -1), # Bottom Left
			#_active_unit.cell + Vector2(1, -1)   # Bottom Right
		#]
		
		#goes through the attackable_cells array and filters the cells to get rid of the corner\
		#okay this should currently work
		if _active_unit.unit_role is not Grenadier:
			for cell in _targetable_cells:
				#only skips the corners if the unit_role is a tank
				#if _active_unit.unit_role is tank:
					#if cell in corners:
						#continue # Skip this cell, don't add it to filtered_cells
						#
				# If we got here, it's a valid cell to draw!
				filtered_cells.append(cell)
		#Grenadier case 
		elif _active_unit.unit_role is Grenadier:
			
			filtered_cells.append_array(_active_unit.unit_role.get_attack_range(_active_unit.cell))
			
			#may need to reverse this 
			#filtered_cells.append_array(_active_unit.unit_role.get_attackable_cells(_active_unit.cell))
			#for cell in _attackable_cells:
				#filtered_cells
		# 4. Draw the filtered list
		if _active_unit:
			_unit_overlay.clear()
			_unit_overlay.draw(filtered_cells)
			_move_overlay_visable = false
			_attack_overlay_visable = true
	else:
		GameConsole.log_message("ERROR","Unit has already attacked!")

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
	_attackable_cells.clear()
	var range_limit
	
	#okay so this is if it is visible then do the move overlay here
	if _move_overlay_visable:
		_move_active_unit(cell)
		clear_overlay()
		#okay so we are using _targetable_cells for the non_grenadier units 
		#the grenadier unit does not need it so we shouldn't use it for them 
		if _active_unit.unit_role is not Grenadier:
			_targetable_cells = get_targetable_cells(_active_unit)

	# now we are going to do the attack block
	elif _attack_overlay_visable:
		# check if they've already acted
		if _has_attacked_this_turn: 
			GameConsole.log_message("ERROR","You have already attacked")
			return

		#NON-GRENADIER BLOCK (Flamethrower, etc.)
		if _active_unit.unit_role is not Grenadier:
			#getting all of what we should attack
			#this doesn't need to be an attack direciton for the grenadier I think
			attack_direction = _active_unit.unit_role.get_attackable_cells_direction(_active_unit.cell, cell)
			
			if cell in _targetable_cells:
				_attackable_cells = _active_unit.unit_role.get_attackable_cells(_active_unit.cell, "null", attack_direction)
				
				for attacking_cell in _attackable_cells:
					#triggers vfx for the attack pls dont break
					_trigger_attack_vfx(attacking_cell)
					if _units.has(attacking_cell):
						apply_damage(attacking_cell, _active_unit.unit_role.attack_roll(_active_unit), _active_unit, _active_unit.unit_role.crit)
						print(attacking_cell)
				
				_has_attacked_this_turn = true
				clear_overlay()

		#GRENADIER BLOCK
		elif _active_unit.unit_role is Grenadier:
			#okay getting the whole range for the unit? 
			#I guess the limit for the attack would be this so we would need it? 
			range_limit = _active_unit.unit_role.get_attack_range(_active_unit.cell)
			
			if cell not in range_limit:
				GameConsole.log_message("ERROR","Out of bombing range")
				return
			
			#that is the blast radius of the attack 
			_attackable_cells = _active_unit.unit_role.get_attackable_cells(cell, "null", attack_direction)
			
			#okay this is just the attack block
			for attacking_cell in _attackable_cells:
				#same thing calls in vfx
				_trigger_attack_vfx(attacking_cell)
				if _units.has(attacking_cell) and attacking_cell in range_limit:
					apply_damage(attacking_cell, _active_unit.unit_role.attack_roll(_active_unit), _active_unit, _active_unit.unit_role.crit)
					print(attacking_cell)
			
			_has_attacked_this_turn = true
			clear_overlay()
	
	#old block of previous implementation
# Only allow movement if the blue tiles are actually showing
	#if _unit_overlay.get_used_cells(0).size() > 0:
		#_move_active_unit(cell)
		#clear_overlay() # Hide tiles after moving
		#_attackable_cells = get_targetable_cells(_active_unit)
		
	
## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	## Only draw the path line if the move overlay is active
	#if _active_unit and _active_unit.is_selected and _move_overlay_visable == true and _unit_overlay.get_used_cells(0).size() > 0 and _active_unit is not BasicEnemy:
		#_unit_path.draw(_active_unit.cell, new_cell)
	var highlighted_attack_cells : Array
	if _move_overlay_visable:
		_unit_path.draw(_active_unit.cell, new_cell)
		
	if _attack_overlay_visable == true and _has_attacked_this_turn == false:
		#Ask the unit role for the specific directional cells
		if new_cell in _targetable_cells:
			attack_direction = ( _active_unit.unit_role.get_attackable_cells_direction(_active_unit.cell, new_cell))
			highlighted_attack_cells = _active_unit.unit_role.get_attackable_cells(_active_unit.cell, "null", attack_direction)
			
		if _active_unit.unit_role is not  Grenadier:
			if new_cell in _targetable_cells:
				attack_direction = ( _active_unit.unit_role.get_attackable_cells_direction(_active_unit.cell, new_cell))
				highlighted_attack_cells = _active_unit.unit_role.get_attackable_cells(_active_unit.cell, "null", attack_direction)
		#should be the grenadier because it doesn't need direction 
		else:
			# so we are getting the attack range of the grenaider 
			#probably should just be this?
			#highlighted_attack_cells = _active_unit.unit_role.get_attack_range(_active_unit.cell)
			#should not be on the origin of unit rather the mouse hover
			#please work
			highlighted_attack_cells = _active_unit.unit_role.get_attackable_cells(new_cell, "null", Vector2.ZERO)
		#Draw the result on the specific AttackOverlay
		#If cleave_cells is empty (diagonal), .draw() will clear the tiles
		if _attack_overlay:
			_attack_overlay.draw(highlighted_attack_cells)

#okay we are going to use a grid clamp, but just reuse it for this attack
#the basic idea is that I am trying to clamp it to the edge of the attack range
#func attack_clamp(grid_position: Vector2) -> Vector2:
	#var out := grid_position
	##Correcting the off by one error
	#out.x = clamp(out.x, 0, size.x - 1.0)
	#out.y = clamp(out.y, 0, size.y - 1.0)
	#return out


##This is the function where the unit will take damage 
func damage_unit(unit : Unit, damage : int):
	unit.unit_role.health - damage
	_update_health_bar.emit()

#a block here for calling the unit attack, ability, and passive ability, unit attack and ability that she doesn't 
func unit_attack():
	#Check if the variable actually holds an object
	if _active_unit != null:
		display_attack_overlay() 
	else:
		push_warning("No active unit to attack!")


func unit_ability():
	if _active_unit != null:
		_active_unit.unit_role.ability(_active_unit)
		#need to recalculate the speed if the _active_unit is the Grenadier doing their speed boost ability
		if _active_unit.unit_role is  Grenadier:
			_active_unit.recalculate_speed() 
			#need to get the walkable cells 
			_walkable_cells = get_walkable_cells(_active_unit)
			
			#now we need to update thy path 
			_unit_path.initialize(_walkable_cells)
			
			#now may need to change to refesh overlay 
			if _move_overlay_visable:
				_unit_overlay.clear()
				_unit_overlay.draw(_walkable_cells)
				
				#Logic for flamethrower ability damage
		if _active_unit.unit_role.explodering:
			if _active_unit.unit_role.explodering == true:
				for unit in _units:
					var u = _units[unit]
					if u.unit_role.on_fire:
						u.unit_role.on_fire = false
						u.unit_role.turns_left_on_fire = 0
						u.update_fire_vfx()
						SoundManager._play_explosionSFX()
						apply_damage(unit, flame_explosion_damage, _active_unit, false)
					else:
						continue
				_active_unit.unit_role.explodering = false
			else:
				pass
	else:
		GameConsole.log_message("ERROR","Attempted to explode flaming enemies, but no one is on fire!")
		push_warning("Attempted to ability, but _active_unit is null!")

func unit_passive():
	if _active_unit != null:
		
		_active_unit.unit_role.passive()
		
	else:
		push_warning("Attempted to passive, but _activecaller_name : String_unit is null!")

func apply_damage(target_cell: Vector2, amount: int, attacker: Unit, crit: bool) -> void:
	var victim = _units[target_cell]
	print(victim)
	var total_damage = max(1, amount - victim.unit_role.defense)
	if attacker:
		#Damage over time passive
		if attacker.unit_role is Flamethrower:
			victim.unit_role.on_fire = true
			victim.unit_role.turns_left_on_fire = fire_dot_turns
			if victim.unit_role.current_health > 0:
				victim.update_fire_vfx()
		#1/4 Grenade damage to self
		if attacker.unit_role is  Grenadier:
			if victim == attacker:
				#quartering the damage to self
				amount *= 0.25
		if attacker.unit_role is Medic:
			total_damage = amount
	victim.unit_role.current_health -= total_damage
	_update_health_bar.emit()
	
	if attacker == null:
		GameConsole.log_message("COMBAT","%s burned! %d!" % [victim.name, abs(total_damage)])
		DamageNumbers.display_number(total_damage, victim.global_position, false)
	elif attacker.unit_role is Medic or attacker.unit_role is Boss_Tower:
		GameConsole.log_message("COMBAT","%s healed! %d!" % [victim.name, abs(total_damage)])
		DamageNumbers.display_number(total_damage, victim.global_position, attacker.unit_role.crit)
	else:
		GameConsole.log_message("COMBAT","%s took %d damage!" % [victim.name, total_damage])
		DamageNumbers.display_number(total_damage, victim.global_position, attacker.unit_role.crit)
		
	if victim.unit_role.current_health >= victim.max_health:
		victim.unit_role.current_health = victim.max_health
	
	if victim.unit_role.current_health <= 0:
		_handle_unit_death(target_cell)

func _handle_unit_death(cell: Vector2) -> void:
	var unit_to_remove = _units[cell]
	
	#this checks if unit has a resource and is in the active party
	if unit_to_remove.unit_resource in PartyManager.active_party:
		var party_index = PartyManager.active_party.find(unit_to_remove.unit_resource)
		if party_index != -1:
			PartyManager.fire_unit(party_index)
			GameConsole.log_message("GAMEMASTER","Unit has died and forever lost")
	
	#it is now walkable!!!
	_walkable_cells.append(cell)
	
	_units.erase(cell)
	initiative_order.erase(unit_to_remove)
	unit_to_remove.queue_free()

#corridnates of spawn for each level
const SPAWN_CONFIG = {
	"Level_0_plains": [
		Vector2(4, 6), Vector2(4, 7), #Front
		Vector2(5, 6), Vector2(5, 7), #Mid
		Vector2(6, 6), Vector2(6, 7)  #Back
	],
	"Level_1_rivers": [
		Vector2(3, 16), Vector2(3, 17),
		Vector2(4, 16), Vector2(4, 17),
		Vector2(5, 16), Vector2(5, 17)
	],
	"Level_2_ruin_ambush": [
		Vector2(18, 12), Vector2(18, 13),
		Vector2(19, 12), Vector2(19, 13),
		Vector2(20, 12), Vector2(20, 13)
	],
	"Level_3_forest": [
		Vector2(3, 16), Vector2(3, 17),
		Vector2(4, 16), Vector2(4, 17),
		Vector2(5, 16), Vector2(5, 17) 
	],
	"Level_4_bridge": [
		Vector2(4, 10), Vector2(4, 11),
		Vector2(5, 10), Vector2(5, 11),
		Vector2(6, 10), Vector2(6, 11) 
	],
	"Level_5_ruins": [
		Vector2(4, 10), Vector2(4, 11),
		Vector2(5, 10), Vector2(5, 11),
		Vector2(6, 10), Vector2(6, 11) 
	],
	"Level_6_fort": [
		Vector2(4, 10), Vector2(4, 11),
		Vector2(5, 10), Vector2(5, 11),
		Vector2(6, 10), Vector2(6, 11) 
	],
	"Level_7_road_ambush": [
		Vector2(18, 10), Vector2(18, 11),
		Vector2(19, 10), Vector2(19, 11),
		Vector2(20, 10), Vector2(20, 11) 
	],
	"Level_8_tough_fight": [
		Vector2(4, 10), Vector2(4, 11),
		Vector2(5, 10), Vector2(5, 11),
		Vector2(6, 10), Vector2(6, 11) 
	],
	"Level_9_boss": [
		Vector2(4, 10), Vector2(4, 11),
		Vector2(5, 10), Vector2(5, 11),
		Vector2(6, 10), Vector2(6, 11) 
	],
		"Tutorialz": [
		Vector2(4, 10), Vector2(4, 11),
		Vector2(5, 10), Vector2(5, 11),
		Vector2(6, 10), Vector2(6, 11) 
	]
}

func spawn_party_from_manager() -> void:
	#gets the current level name from the scene tree
	var current_level = get_tree().current_scene.name
	
	#selects the spawn array based on the level name
	var spawn_points = SPAWN_CONFIG.get(current_level)
	
	#if the level isn't in SPAWN_CONFIG exit early
	if spawn_points == null:
		print("No spawn points defined for: ", current_level)
		return
	
	var unit_scene = preload("res://Entities/Units/Unit.tscn")
	
	for i in range(PartyManager.active_party.size()):
		#stops if we run out of defined spawn points for this level
		if i >= spawn_points.size():
			break
			
		var data = PartyManager.active_party[i]
		var new_unit = unit_scene.instantiate() as Unit
		
		if data.role != "":
			new_unit.name = data.role
		else:
		#incase it doesnt work
			new_unit.name = data.resource_path.get_file().get_basename()
		#resets medic heal
		if "has_global_healed" in data:
			data.has_global_healed = false
		
		new_unit.unit_resource = data
		#so the unit_role setter can trigger correctly
		new_unit.unit_role = data
		new_unit.grid = PartyManager.GRID_RES 
		
		add_child(new_unit)
		
		#set coordinates based on the level-specific list
		new_unit.cell = spawn_points[i]
		new_unit.position = new_unit.grid.calculate_map_position(new_unit.cell)
	
	# Refresh units dictionary for movement logic
	
	_reinitialize()

func _check_for_victory_or_defeat() -> void:
	var current_level = get_tree().current_scene.name
	var player_alive := false
	var enemies_alive := false
	
	# Scan the initiative list to see who is still standing
	for unit in initiative_order:
		if unit.is_in_group("player_units"):
			player_alive = true
		elif unit is BasicEnemy or unit is HunterEnemy or unit is BigEnemy or unit is BossMain or unit is BossTower or unit is Tower or unit is TrainingDummy or unit is WalkingTrainingDummy:
			enemies_alive = true
			
	if not enemies_alive:
		if current_level == "Tutorialz":
			ui.combat_end_label_ui.text = "LOSER"
			get_tree().paused = true
			ui.combat_end_ui.visible = true
			ui.continue_button_ui.visible = false
			ui.battle_ui.visible = false
			return
		
		for unit in _units:
			_units[unit].unit_role.current_health
		grant_xp()
		ui.combat_end_label_ui.text = "WINNER!"
		get_tree().paused = true
		ui.combat_end_ui.visible = true
		ui.battle_ui.visible = false
	elif not player_alive:
		ui.combat_end_label_ui.text = "LOSER"
		get_tree().paused = true
		ui.combat_end_ui.visible = true
		ui.continue_button_ui.visible = false
		ui.battle_ui.visible = false

func grant_xp() -> void:
	print("Granting victory XP to survivors...")
	for unit in initiative_order:
		if unit.is_in_group("player_units") and is_instance_valid(unit):
			unit.unit_role.xp += 25
			print("%s gained 25 XP. Total: %d" % [unit.unit_role.role, unit.unit_role.xp])
	_check_for_level_ups()

func _check_for_level_ups() -> void:
	for unit in initiative_order:
		if unit.is_in_group("player_units") and is_instance_valid(unit):
			
			#checks if unit is ready to level up!
			while unit.unit_role.xp >= 100:
				unit.unit_role.level += 1
				unit.unit_role.xp -= 100
				unit.unit_role.defense += 1 # Add +1 Defense per level
				unit.unit_role.attack_stat += 1
				unit.unit_role.max_hp += 2
				unit.unit_role.luck += 1
				
				GameConsole.log_message("LEVELUP","LEVEL UP! %s is now Level %d." % [unit.unit_role.role, unit.unit_role.level])

#determines what vfx to play based on the unit_role
func _trigger_attack_vfx(cell: Vector2) -> void:
	#fallback animation just in case
	var vfx_type = "slash_attack" 
	
	#checks units role to determine what vfx to use
	if _active_unit.unit_role is Tank:
		vfx_type = "slash_attack"
		SoundManager._play_slashSFX()
	elif _active_unit.unit_role is Flamethrower:
		vfx_type = "fire_attack"
		SoundManager._play_flamethrowerSFX()
	elif _active_unit.unit_role is Grenadier:
		vfx_type = "explosion_attack"
		SoundManager._play_explosionSFX()
	elif _active_unit.unit_role is Musketeer:
		vfx_type = "gun_attack"
		SoundManager._play_gunSFX()
	elif _active_unit.unit_role is Medic or _active_unit.unit_role is Boss_Tower:
		vfx_type = "heal_attack"
		SoundManager._play_healSFX()
	#this ensures the animation is centered on the square
	var world_pos = grid.calculate_map_position(cell)
	
	VfxManager.play_vfx(vfx_type, world_pos)
