#Special Thanks to this Repository for helping build the basis of the movement system of our game. 
#https://github.com/gdquest-demos/godot-2d-tactical-rpg-movement/tree/main/godot4 
#Special thanks to this as well to help explain the code 
#https://www.gdquest.com/tutorial/godot/2d/tactical-rpg-movement/lessons/01.grid/

## Draws a selected unit's walkable tiles.
class_name UnitOverlay
extends TileMap


## Fills the tilemap with the cells, giving a visual representation of the cells a unit can walk.
func draw(cells: Array) -> void:
	clear()
	for cell in cells:
		set_cell(0, cell, 0, Vector2i(0,0))
