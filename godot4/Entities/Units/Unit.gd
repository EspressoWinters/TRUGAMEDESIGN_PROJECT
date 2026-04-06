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

@export var current_health: int
@export var max_health: int
var gameboard: GameBoard
@export var initiative_stat := 0


## Setting the texture and if it doesn't have a sprite it waits until it has one or have been created
@export var skin: Texture:
	set(value):
		skin = value
		if not _sprite:
			# Wait until the ready() is called
			await ready
		_sprite.texture = value
## Set for each sprite to line up with the shadow
@export var skin_offset := Vector2.ZERO:
	set(value):
		skin_offset = value
		if not _sprite:
			await ready
		_sprite.position = value

## Coordinates of the current cell the cursor moved to.
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
@onready var _sprite: Sprite2D = $PathFollow2D/Sprite
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D

#When it loads into the scene tree
func _ready() -> void:
	move_range = unit_role.speed
	move_speed = unit_role.speed * 100
	max_health = unit_role.max_hp
	current_health = max_health
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
	_health_bar.value = current_health
	await get_tree().process_frame
	gameboard._update_health_bar.connect(set_health_bar)


func _process(delta: float) -> void:
	#moves the unit along the path by delta
	_path_follow.progress += move_speed * delta
	#When the walking is finished resetes path progress and emits walk signal for gameboard managment
	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		_path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")


## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	_is_walking = true

func set_health_bar() -> void:
	$Healthbar.value = current_health

func heal(amount: int) -> void:
	current_health = current_health + amount
	$Healthbar.value = current_health
	
	if current_health > max_health:
		current_health = max_health
