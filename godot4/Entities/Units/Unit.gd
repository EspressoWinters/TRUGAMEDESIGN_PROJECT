#Special Thanks to this Repository for helping build the basis of the movement system of our game. 
#https://github.com/gdquest-demos/godot-2d-tactical-rpg-movement/tree/main/godot4 
#Special thanks to this as well to help explain the code 
#https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/lessons/01.grid/


## This unit script handles the unit moving along the path and sends a signal to the Gameboard when its finished

#this allows us to run it in the editor
@tool
class_name Unit
extends Path2D

## Emit a signal when the walk is finished 
signal walk_finished

@export var unit_role: Resource

## Use the grid to know the grid coordinates and know get access to it calculations
@export var grid: Resource
## Distance units can move in tiles 
var move_range :int
## Speed of it visually moving, doesn't actually affect movement
var move_speed :int
var is_taunting: bool = false
#stores the reference of which resource it is using
var unit_resource: Unit_Interaction
@onready var sprite: Sprite2D = $PathFollow2D/Sprite
@onready var on_fire_vfx: AnimatedSprite2D = $OnFireAnimation
@onready var crit_buff: AnimatedSprite2D = $CritBuff
@onready var taunt_buff: AnimatedSprite2D = $TauntBuff

@export var max_health: int
var gameboard: GameBoard
@export var initiative_stat := 0

## Coordinates of the current cell the cursor moved to.
#from the tutorial 
var cell := Vector2.ZERO:
	set(value):
		# When the grid value changes, we want to clamp it to ensure it within the boundary
		cell = grid.grid_clamp(value)
## Animation or not, if selected then it is True.
var is_selected := false:
	set(value):
		is_selected = value
		if not _anim_player:
			await ready
			
		if is_selected:
		# Loops animation
			_anim_player.play("selected") 
		else:
			#Stops Animation
			_anim_player.play("idle")
##This is where starts the process of it moving along
var _is_walking := false:
	set(value):
		_is_walking = value
		set_process(_is_walking)

#Call it when the nodes are ready to load the sprite, the animation, and the path follow 2d 
#The path follow 2D is what the "animation" follows along
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D

#When it loads into the scene tree

#I just copied it because I had to overwrite the parent thing 
#from tutorial but modified 
func _ready() -> void:
	#everyone gets a unique resource file 
	unit_role = unit_role.duplicate()
	
	sprite.texture = unit_role.skin
	move_range = unit_role.speed
	move_speed = unit_role.speed * 100
	max_health = unit_role.max_hp
	if unit_role is Basic_enemy or unit_role is Hunter_enemy or unit_role is Big_enemy or unit_role is TrainingDummy_class or unit_role is Boss_Main or unit_role is Boss_Tower:
		unit_role.current_health = max_health
	
	#makes sure the object doesn't start the _process function
	set_process(false)
	#locks it so it doesn't rotate along the path
	#basically instead of looking statically at one side, it would "follow" the direction of the path and rotate itself
	_path_follow.rotates = false 
	#just getting the pixel and the grid values so that we can use them later
	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	var _health_bar = get_node_or_null("Healthbar")
	
	_health_bar.max_value = max_health
	_health_bar.value = unit_role.current_health
	await get_tree().process_frame
	gameboard._update_health_bar.connect(set_health_bar)

#from the tutorial 
func _process(delta: float) -> void:
	#moves the unit along the path by delta
	_path_follow.progress += move_speed * delta
	#print(_path_follow.progress)
	#When the walking is finished resetes path progress and emits walk signal for gameboard managment
	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		_path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")
		

##Recalculating the speed for some edge cases'
#like the grendadier speed boost 
func recalculate_speed():
	move_range = unit_role.speed
	move_speed = unit_role.speed * 100 
	

#checking whether you are being jumped utterly
func is_surronded():
	
	var top = cell + Vector2(0,-1)
	var right = cell + Vector2(1,0)
	var left = cell + Vector2(-1,0)
	var bottom = cell + Vector2(0, 1)
	
	var top_tile_data: TileData = gameboard.tile_map.get_cell_tile_data(0,top)
	var right_tile_data: TileData = gameboard.tile_map.get_cell_tile_data(0,right)
	var left_tile_data: TileData = gameboard.tile_map.get_cell_tile_data(0,left)
	var bottom_tile_data: TileData = gameboard.tile_map.get_cell_tile_data(0,bottom)

	#top case
	
	if (gameboard.is_occupied(top)) and (gameboard.is_occupied(right)) and (gameboard.is_occupied(left)) and (gameboard.is_occupied(bottom)):
		return true  
	
	
	return false
	
	
	
 



#just using this logic to check if surronded or not

#elif direction == Vector2(-1,0):
		#attackable_cells.append(origin_cell + Vector2(-1,0)) 
#
	##Right 
	#elif direction == Vector2(1,0):
		#attackable_cells.append(origin_cell + Vector2(1,0)) 
#
	##Down
	#elif direction == Vector2(0,1):
		#attackable_cells.append(origin_cell + Vector2(0,1))
	#
	##up
	#elif direction == Vector2(0,-1):
		#attackable_cells.append(origin_cell + Vector2(0,-1))


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
#from the tutorial
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	_is_walking = true

func set_health_bar() -> void:
	$Healthbar.value = unit_role.current_health

func heal(amount: int) -> void:
	unit_role.current_health = unit_role.current_health + amount
	$Healthbar.value = unit_role.current_health
	
	if unit_role.current_health > max_health:
		unit_role.current_health = max_health
		
#Do not delete: it is needed for the extended emenies to not crash
func find_closet_human_character():
	print("")
	
func check_and_attack_adjacent():
	print("")

func _on_container_mouse_entered() -> void:
	$Area2D/Panel/HealthLabel.text = "HP: %d" % [unit_role.current_health]
	$Area2D/Panel.visible = true

func _on_container_mouse_exited() -> void:
	$Area2D/Panel.visible = false

func update_fire_vfx():
	on_fire_vfx.visible = unit_role.on_fire
