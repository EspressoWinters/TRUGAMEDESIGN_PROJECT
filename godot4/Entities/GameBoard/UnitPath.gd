#Special Thanks to this Repository for helping build the basis of the movement system of our game. 
#https://github.com/gdquest-demos/godot-2d-tactical-rpg-movement/tree/main/godot4 
#Special thanks to this as well to help explain the code 
#https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/lessons/01.grid/

## Draws the unit's movement path using an autotile.
class_name UnitPath
extends TileMap

@export var grid: Resource

var _pathfinder: PathFinder
var current_path := PackedVector2Array()


## Creates a new PathFinder that uses the AStar algorithm to find a path between two cells among
## the `walkable_cells`.
func initialize(walkable_cells: Array) -> void:
	_pathfinder = PathFinder.new(grid, walkable_cells)


## Finds and draws the path between `cell_start` and `cell_end`
func draw(cell_start: Vector2, cell_end: Vector2) -> void:
	if _pathfinder == null:
		return
	clear()
	current_path = _pathfinder.calculate_point_path(cell_start, cell_end)
	set_cells_terrain_connect(0, current_path, 0, 0)


## Stops drawing, clearing the drawn path and the `_pathfinder`.
func stop() -> void:
	_pathfinder = null
	clear()
