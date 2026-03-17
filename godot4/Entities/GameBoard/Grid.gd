#Special Thanks to this Repository for helping build the basis of the movement system of our game. 
#https://github.com/gdquest-demos/godot-2d-tactical-rpg-movement/tree/main/godot4 
#Special thanks to this as well to help explain the code 
#https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/lessons/01.grid/

## The grid defines the board limits, calculations between pixels and coordiantes, and keeps it within the boundaries we need 
class_name Grid
extends Resource

## The grid's rows and columns
## This will decide how big the grid is
@export var size := Vector2(80, 80)

## Size of the cells 16 by 16
@export var cell_size := Vector2(16, 16)

## Half of ``cell_size``, we need this to calculate the center of the cell
var _half_cell_size = cell_size / 2


## Returns the cell's center position from the grid coordinates
func calculate_map_position(grid_position: Vector2) -> Vector2:
	return grid_position * cell_size + _half_cell_size
 #used for astar

## Returns the cells center pixel position to grid coordinates
func calculate_grid_coordinates(map_position: Vector2) -> Vector2:
	return (map_position / cell_size).floor()


## Checking whether it is in or out of bounds
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	return out and cell_coordinates.y >= 0 and cell_coordinates.y < size.y


## Makes the `grid_position` fit within the grid's bounds.
## The clamp ensures that the coordinate is within the grids bound by either forcing it to be the grids "minimum" or "maximum" point
func grid_clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	#Correcting the off by one error
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out
