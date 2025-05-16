class_name Ghost
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var target_cell_panel: Panel = %TargetCell
@onready var target_cell_coordinates_label: Label = %TargetCellCoordinates
@onready var target_cell_position_label: Label = %TargetCellPosition

const GRID = preload("res://resources/Grid.tres")
var _current_cell_coordinates: Vector2i
var _current_cell_position: Vector2
var _desired_cell_coordinates : Vector2i
var _desired_cell_position : Vector2
var _target := Vector2(80, 40)
var target_coordinates : Vector2i

const WALKABLE_CELLS = preload("res://resources/WalkableCells.tres")

var _direction := Vector2.RIGHT
var _speed := 1.0

func _ready() -> void:
	animated_sprite_2d.play("right")
	_calculate_next_desired_position()

func _physics_process(delta: float) -> void:
	_current_cell_coordinates = GRID.calculate_cell_coordinates(global_position)
	_current_cell_position = GRID.calculate_cell_position(_current_cell_coordinates)
	if target_coordinates:
		target_cell_panel.global_position = GRID.calculate_cell_position(target_coordinates) - Vector2(4.0, 4.0)
		target_cell_coordinates_label.text = str(target_coordinates)
		target_cell_position_label.text = str(target_cell_panel.global_position)

func _calculate_next_desired_position() -> void:
	_desired_cell_coordinates = _current_cell_coordinates + Vector2i(_direction)
	_desired_cell_position = GRID.calculate_cell_position(_desired_cell_coordinates)
	if !WALKABLE_CELLS.is_walkable(_desired_cell_coordinates):
		_desired_cell_position = _current_cell_position
