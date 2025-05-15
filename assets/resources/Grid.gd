class_name Grid
extends Resource

## The grid's size in rows and columns
@export var size := Vector2(20, 20)
## The size of a cell in pixels
@export var cell_size := Vector2(80, 80)

var _half_cell_size = cell_size / 2

## Returns the coordinates of the cell on the grid given a position on the map.
func calculate_cell_coordinates(glob_pos: Vector2) -> Vector2i:
	return (glob_pos / cell_size).floor()
	
## Returns the position of a cell's center in pixels
func calculate_cell_position(cell_coord: Vector2i) -> Vector2:
	_half_cell_size = cell_size / 2
	return Vector2(cell_coord) * cell_size + _half_cell_size

## Returns true if the `cell_coordinates` are within the grid.
func is_within_bounds(cell_coordinates: Vector2) -> bool:
	var out := cell_coordinates.x >= 0 and cell_coordinates.x < size.x
	return out and cell_coordinates.y > 0 and cell_coordinates.y < size.y

## Makes the `grid_position` fit within the grid's bounds.
func clamp(grid_position: Vector2) -> Vector2:
	var out := grid_position
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out

## Given Vector2 coordinates, calculates and returns the corresponding integer index. You can use
## this function to convert 2D coordinates to a 1D array's indices.
func as_index(cell: Vector2) -> int:
	return int(cell.x + size.x * cell.y)
