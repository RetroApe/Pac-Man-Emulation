extends CharacterBody2D

@onready var cell_position: Label = %CellPosition
@onready var cell_coordinates: Label = %CellCoordinates
@onready var is_walkable: Label = %IsWalkable
@onready var desired_cell: Panel = %DesiredCell

const GRID = preload("res://assets/resources/Grid.tres")
var _current_cell_coordinates: Vector2i
var _current_cell_position: Vector2
var _desired_cell_coordinates : Vector2i
var _desired_cell_position : Vector2

const WALKABLE_CELLS = preload("res://assets/resources/WalkableCells.tres")

var _direction := Vector2.RIGHT
var _speed := 1.0

func _ready() -> void:
	_calculate_next_desired_position()

func _physics_process(delta: float) -> void:
	_current_cell_coordinates = GRID.calculate_cell_coordinates(global_position)
	_current_cell_position = GRID.calculate_cell_position(_current_cell_coordinates)
	
	_process_input()
	
	_calculate_next_desired_position()
	if WALKABLE_CELLS.is_walkable(_desired_cell_coordinates):
		is_walkable.text = "true"
	else:
		is_walkable.text = "false"
	
	cell_coordinates.text = "Cell Coordinates: " + str(_current_cell_coordinates)
	cell_position.text = "Cell Position: " + str(_current_cell_position)
	
	#global_position = global_position.move_toward(desired_cell_position, delta * 60.0)
	if global_position.x != _desired_cell_position.x:
		var dir_x : float = sign(_desired_cell_position.x - global_position.x)
		_move_x(dir_x * delta * 60)
	if global_position.y != _desired_cell_position.y:
		var dir_y : float = sign(_desired_cell_position.y - global_position.y)
		_move_y(dir_y * delta * 60)


func _calculate_next_desired_position() -> void:
	_desired_cell_coordinates = _current_cell_coordinates + Vector2i(_direction)
	_desired_cell_position = GRID.calculate_cell_position(_desired_cell_coordinates)
	desired_cell.global_position = _desired_cell_position - Vector2(4.0, 4.0)
	if !WALKABLE_CELLS.is_walkable(_desired_cell_coordinates):
		_desired_cell_position = _current_cell_position

func _process_input() -> void:
	var can_change_direction := (
		global_position.x > _current_cell_position.x - 3.0 and global_position.x < _current_cell_position.x + 4.0 and
		global_position.y > _current_cell_position.y - 3.0 and global_position.y < _current_cell_position.y + 4.0
	)
	if (
		Input.is_action_pressed("move_up") and 
		can_change_direction and
		WALKABLE_CELLS.is_walkable(_current_cell_coordinates + Vector2i.UP)
	):
		_direction = Vector2.UP
	if (
		Input.is_action_pressed("move_left") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(_current_cell_coordinates + Vector2i.LEFT)
	):
		_direction = Vector2.LEFT
	if (
		Input.is_action_pressed("move_down") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(_current_cell_coordinates + Vector2i.DOWN)
	):
		_direction = Vector2.DOWN
	if (
		Input.is_action_pressed("move_right") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(_current_cell_coordinates + Vector2i.RIGHT)
	):
		_direction = Vector2.RIGHT
	#if Input.is_action_just_pressed("stop"): _direction = Vector2.ZERO

func _move_x(velocity_x: float):
	global_position.x += velocity_x
func _move_y(velocity_y: float):
	global_position.y += velocity_y
