class_name PacMan
extends CharacterBody2D

signal energizer_eaten
signal dot_eaten
signal death_animation_finished

@onready var desired_cell: Panel = %DesiredCell
@onready var this_area: Area2D = %Area2D
@onready var dots_number: Label = %DotsNumber
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var eat_sfx_1: AudioStreamPlayer2D = %EatSFX1
@onready var eat_sfx_2: AudioStreamPlayer2D = %EatSFX2
@onready var death_sfx: AudioStreamPlayer2D = %DeathSFX
@onready var death_finished_sfx: AudioStreamPlayer2D = %DeathFinishedSFX

const GRID = preload("res://resources/Grid.tres")
var current_cell_coordinates: Vector2i
var _current_cell_position: Vector2
var _desired_cell_coordinates : Vector2i
var _desired_cell_position : Vector2

const WALKABLE_CELLS = preload("res://resources/WalkableCells.tres")

var direction := Vector2.RIGHT
var _speed := 1.0
var _normal_speed := 1.0
var _fright_speed := 1.0
var _dots_eaten := 0
var _skip_frames := 0
var _start_position : Vector2
var _start_direction := Vector2.RIGHT

func _ready() -> void:
	_dots_eaten = GameState.dots_eaten
	_start_position = global_position
	this_area.area_entered.connect(_on_area_entered)
	animated_sprite_2d.animation_finished.connect(_on_pacman_death_finished)
	ready_the_pacman()

func ready_the_pacman() -> void:
	_set_pacmans_speed()
	set_physics_process(true)
	animated_sprite_2d.play("default")
	_calculate_next_desired_position()

func _set_pacmans_speed() -> void:
	if GameState.current_level_counter == 1:
		_normal_speed = 1.0
		_fright_speed = 1.125
	elif GameState.current_level_counter >= 2 and GameState.current_level_counter <= 4:
		_normal_speed = 1.125
		_fright_speed = 1.1875
	elif GameState.current_level_counter >= 5 and GameState.current_level_counter <= 20:
		_normal_speed = 1.25
		_fright_speed = 1.25
	else:
		_normal_speed = 1.125
		_fright_speed = 1.125
	_speed = _normal_speed

func _physics_process(delta: float) -> void:
	if _skip_frames > 0:
		_skip_frames -= 1
		return
	current_cell_coordinates = GRID.calculate_cell_coordinates(global_position)
	_current_cell_position = GRID.calculate_cell_position(current_cell_coordinates)
	
	_process_input()
	
	_calculate_next_desired_position()
	
	_position_correction()
	
	#global_position = global_position.move_toward(desired_cell_position, delta * 60.0)
	if !is_equal_approx(global_position.x, _desired_cell_position.x):
		var dir_x : float = sign(_desired_cell_position.x - global_position.x)
		_move_x(dir_x * delta * 60 * _speed)
	if !is_equal_approx(global_position.y, _desired_cell_position.y):
		var dir_y : float = sign(_desired_cell_position.y - global_position.y)
		_move_y(dir_y * delta * 60 * _speed)
	_wrap_around_the_screen()
	
	if global_position == _desired_cell_position:
		animated_sprite_2d.stop()

func _position_correction() -> void:
	if (
		global_position.x >= _desired_cell_position.x - _speed / 2.0 and
		global_position.x <= _desired_cell_position.x + _speed / 2.0
	):
		global_position.x = _desired_cell_position.x
	if (
		global_position.y >= _desired_cell_position.y - _speed / 2.0 and
		global_position.y <= _desired_cell_position.y + _speed / 2.0
	):
		global_position.y = _desired_cell_position.y

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
		direction = Vector2.UP
		animated_sprite_2d.play("up")
	if (
		Input.is_action_pressed("move_left") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(current_cell_coordinates + Vector2i.LEFT)
	):
		direction = Vector2.LEFT
		animated_sprite_2d.play("left")
	if (
		Input.is_action_pressed("move_down") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(current_cell_coordinates + Vector2i.DOWN)
	):
		direction = Vector2.DOWN
		animated_sprite_2d.play("down")
	if (
		Input.is_action_pressed("move_right") and
		can_change_direction and
		WALKABLE_CELLS.is_walkable(current_cell_coordinates + Vector2i.RIGHT)
	):
		direction = Vector2.RIGHT
		animated_sprite_2d.play("right")
	#if Input.is_action_just_pressed("stop"): _direction = Vector2.ZERO

func _calculate_next_desired_position() -> void:
	_desired_cell_coordinates = current_cell_coordinates + Vector2i(direction)
	_desired_cell_position = GRID.calculate_cell_position(_desired_cell_coordinates)
	desired_cell.global_position = _desired_cell_position - Vector2(4.0, 4.0)
	if !WALKABLE_CELLS.is_walkable(_desired_cell_coordinates):
		_desired_cell_position = _current_cell_position

func _move_x(velocity_x: float):
	global_position.x += velocity_x
func _move_y(velocity_y: float):
	global_position.y += velocity_y

func _wrap_around_the_screen() -> void:
	if global_position.x <= GRID.calculate_cell_position(Vector2i(-2, 0)).x:
		global_position.x = GRID.calculate_cell_position(Vector2i(GRID.size) + Vector2i(1, 0)).x
	elif global_position.x >= GRID.calculate_cell_position(Vector2i(GRID.size) + Vector2i(1, 0)).x:
		global_position.x = GRID.calculate_cell_position(Vector2i(-2, 0)).x

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("dots"):
		match GameState.dots_eaten % 2:
			0:
				eat_sfx_1.play()
			1:
				eat_sfx_2.play()
		_skip_frames = 1
		_dots_eaten += 1
		GameState.dots_eaten += 1
		dot_eaten.emit(_dots_eaten)
		dots_number.text = "Dots: " + str(_dots_eaten)
		area.queue_free()
		if area.is_in_group("energizers"):
			_skip_frames = 3
			energizer_eaten.emit()
			area.queue_free()
			_speed = _fright_speed
		if _dots_eaten == 244:
			animated_sprite_2d.animation = "default"

func death() -> void:
	set_physics_process(false)
	animated_sprite_2d.pause()
	get_tree().create_timer(1.0).timeout.connect(func() -> void:
		animated_sprite_2d.play("death")
		animated_sprite_2d.frame_changed.connect(_on_frame_changed)
	)
	print("Pac-Man Dead")

func _on_frame_changed() -> void:
	if animated_sprite_2d.animation == "death":
		match animated_sprite_2d.frame:
			1:
				death_sfx.play()
			10:
				death_sfx.stop()
				death_finished_sfx.play()
			11:
				death_finished_sfx.play()
				animated_sprite_2d.frame_changed.disconnect(_on_frame_changed)
		

func _on_pacman_death_finished() -> void:
	if animated_sprite_2d.animation == "death":
		death_animation_finished.emit()
		global_position = _start_position
		direction = _start_direction
		

func on_frightened_finished() -> void:
	_speed = _normal_speed
