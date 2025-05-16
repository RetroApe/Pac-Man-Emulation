class_name PacMan
extends CharacterBody2D

@onready var cell_coordinates: Label = %CellCoordinates
@onready var is_walkable: Label = %IsWalkable
@onready var desired_cell: Panel = %DesiredCell
@onready var this_area: Area2D = %Area2D
@onready var dots_number: Label = %DotsNumber
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

const GRID = preload("res://resources/Grid.tres")
var current_cell_coordinates: Vector2i
var _current_cell_position: Vector2
var _desired_cell_coordinates : Vector2i
var _desired_cell_position : Vector2

const WALKABLE_CELLS = preload("res://resources/WalkableCells.tres")

var _direction := Vector2.RIGHT
var _speed := 1.0
var _dots_eaten := 0

func _ready() -> void:
	animated_sprite_2d.play("right")
	_calculate_next_desired_position()
	this_area.area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	current_cell_coordinates = GRID.calculate_cell_coordinates(global_position)
	_current_cell_position = GRID.calculate_cell_position(current_cell_coordinates)
	
	_process_input()
	
	_calculate_next_desired_position()
	if WALKABLE_CELLS.is_walkable(_desired_cell_coordinates):
		is_walkable.text = "true"
	else:
		is_walkable.text = "false"
	
	cell_coordinates.text = "Cell Coordinates: " + str(current_cell_coordinates)
	
	#global_position = global_position.move_toward(desired_cell_position, delta * 60.0)
	if global_position.x != _desired_cell_position.x:
		var dir_x : float = sign(_desired_cell_position.x - global_position.x)
		_move_x(dir_x * delta * 60)
	if global_position.y != _desired_cell_position.y:
		var dir_y : float = sign(_desired_cell_position.y - global_position.y)
		_move_y(dir_y * delta * 60)
	if global_position == _desired_cell_position:
		animated_sprite_2d.stop()

func _process_input() -> void:
	var can_change_direction := (
		global_position.x > _current_cell_position.x - 3.0 and global_position.x < _current_cell_position.x + 4.0 and
		global_position.y > _current_cell_position.y - 3.0 and global_position.y < _current_cell_position.y + 4.0
	)
	if (
		Input.is_action_pressed("move_up") and 
		can_change_direction and
		WALKABLE_CELLS.is_walkable(current_cell_coordinates + Vector2i.UP)
	):
		_direction = Vector2.UP
		animated_sprite_2d.play("up")
	if (
		Input.is_action_pressed("move_left") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(current_cell_coordinates + Vector2i.LEFT)
	):
		_direction = Vector2.LEFT
		animated_sprite_2d.play("left")
	if (
		Input.is_action_pressed("move_down") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(current_cell_coordinates + Vector2i.DOWN)
	):
		_direction = Vector2.DOWN
		animated_sprite_2d.play("down")
	if (
		Input.is_action_pressed("move_right") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(current_cell_coordinates + Vector2i.RIGHT)
	):
		_direction = Vector2.RIGHT
		animated_sprite_2d.play("right")
	#if Input.is_action_just_pressed("stop"): _direction = Vector2.ZERO

func _calculate_next_desired_position() -> void:
	_desired_cell_coordinates = current_cell_coordinates + Vector2i(_direction)
	_desired_cell_position = GRID.calculate_cell_position(_desired_cell_coordinates)
	desired_cell.global_position = _desired_cell_position - Vector2(4.0, 4.0)
	if !WALKABLE_CELLS.is_walkable(_desired_cell_coordinates):
		_desired_cell_position = _current_cell_position


func _move_x(velocity_x: float):
	global_position.x += velocity_x
func _move_y(velocity_y: float):
	global_position.y += velocity_y

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("dots"):
		_dots_eaten += 1
		dots_number.text = "Dots: " + str(_dots_eaten)
		area.queue_free()

func death() -> void:
	print("Pac-Man Dead")
