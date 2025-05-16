class_name Ghost
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var target_cell_panel: Panel = %TargetCell
@onready var desired_cell_position_panel: Panel = %DesiredCellPositionPanel
@onready var target_cell_coordinates_label: Label = %TargetCellCoordinates
@onready var current_cell_coordinates_label: Label = %CurrentCellCoordinates

const GRID = preload("res://resources/Grid.tres")
var _current_cell_coordinates : Vector2i
var _current_cell_position : Vector2
var _desired_cell_coordinates : Vector2i
var _desired_cell_position : Vector2
var target_coordinates : Vector2i
var target_position : Vector2

const WALKABLE_CELLS = preload("res://resources/WalkableCells.tres")

var _direction := Vector2i.RIGHT
var _speed := 1.0

func _ready() -> void:
	_current_cell_coordinates = GRID.calculate_cell_coordinates(global_position)
	_current_cell_position = GRID.calculate_cell_position(_current_cell_coordinates)
	animated_sprite_2d.play("right")
	_calculate_next_desired_position()

func _physics_process(delta: float) -> void:
	_current_cell_coordinates = GRID.calculate_cell_coordinates(global_position)
	_current_cell_position = GRID.calculate_cell_position(_current_cell_coordinates)
	if target_coordinates:
		target_position = GRID.calculate_cell_position(target_coordinates)
		target_cell_panel.global_position = target_position - Vector2(4.0, 4.0)
		target_cell_coordinates_label.text = str(target_coordinates)
	current_cell_coordinates_label.text = str(_current_cell_coordinates)
	desired_cell_position_panel.global_position = _desired_cell_position - Vector2(4.0, 4.0)
	
	if global_position == _desired_cell_position:
		_calculate_next_desired_position()
		_calculate_next_move()
	
	global_position = global_position.move_toward(_desired_cell_position, 60.0 * delta * _speed)

func _calculate_next_desired_position() -> void:
	_desired_cell_coordinates = _current_cell_coordinates + _direction
	_desired_cell_position = GRID.calculate_cell_position(_desired_cell_coordinates)
	desired_cell_position_panel.global_position = _desired_cell_position - Vector2(4.0, 4.0)
	if !WALKABLE_CELLS.is_walkable(_desired_cell_coordinates):
		_desired_cell_position = _current_cell_position

func _calculate_next_move() -> void:
	var possible_directions := [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	# Remove backward direction
	possible_directions.erase(- _direction)
	# Remove non-walkable directions
	for i in range(possible_directions.size()):
		var to_check_walkable : Vector2i = _desired_cell_coordinates + possible_directions[i]
		if !WALKABLE_CELLS.is_walkable(to_check_walkable):
			possible_directions[i] = null
	while possible_directions.find(null) != -1:
		possible_directions.erase(null)
	if possible_directions.size() == 1:
		_direction = possible_directions[0]
		return
	# Choose direction closest to the target
	var length_to_target : Array[float]= []
	var cell_pos : Vector2
	for dir in possible_directions:
		cell_pos = GRID.calculate_cell_position(_desired_cell_coordinates + dir)
		length_to_target.append((target_position - cell_pos).length())
	_direction = possible_directions[0]
	if length_to_target.is_empty():
		return
	var min_length := length_to_target[0]
	for i in range(length_to_target.size()):
		if length_to_target[i] < min_length:
			min_length = length_to_target[i]
			_direction = possible_directions[i]
