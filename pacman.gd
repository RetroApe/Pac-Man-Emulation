extends CharacterBody2D

@onready var cell_position: Label = %CellPosition
@onready var cell_coordinates: Label = %CellCoordinates
@onready var global_coordinates: Label = %GlobalCoordinates

const GRID = preload("res://Grid.tres")
var _direction := Vector2.RIGHT
var _speed := 1.0

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up") and !%Up.is_colliding():
		_direction = Vector2.UP
	if Input.is_action_just_pressed("move_left") and !%Left.is_colliding():
		_direction = Vector2.LEFT
	if Input.is_action_just_pressed("move_down") and !%Down.is_colliding():
		_direction = Vector2.DOWN
	if Input.is_action_just_pressed("move_right") and !%Right.is_colliding():
		_direction = Vector2.RIGHT
	if Input.is_action_just_pressed("stop"): _direction = Vector2.ZERO
	_move(_direction)
	var cell_coordinates_vector := GRID.calculate_cell_coordinates(global_position)
	var cell_position_vector := GRID.calculate_cell_position(cell_coordinates_vector)
	global_coordinates.text = "Position: " + str(global_position)
	cell_coordinates.text = "Cell Coordinates: " + str(cell_coordinates_vector)
	cell_position.text = "Cell Position: " + str(cell_position_vector)

func _move(dir: Vector2) -> void:
	global_position += dir * _speed
	
	
