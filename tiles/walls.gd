class_name Walls
extends TileMapLayer

@onready var gate: Sprite2D = %Gate

var _used_cells : Array[Vector2i]
var _offset_atlas_coord_by := Vector2i(0, 3)

func toggle_walls() -> void:
	if gate.visible:
		gate.visible = false
	_used_cells = get_used_cells()
	for cell in _used_cells:
		var atlas_coord_cell := get_cell_atlas_coords(cell)
		set_cell(cell, 0, atlas_coord_cell + _offset_atlas_coord_by)
	_offset_atlas_coord_by *= -1
