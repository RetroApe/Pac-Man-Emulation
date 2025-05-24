class_name Ghost
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var frightened_timer: Timer = %FrightenedTimer

@onready var target_cell_panel := Panel.new()
@onready var desired_cell_position_panel := Panel.new()
@onready var personal_dot_counter_label: Label = %PersonalDotCounterLabel
@onready var red_green_indicator: Panel = %RedGreenIndicator

const WALKABLE_CELLS = preload("res://resources/WalkableCells.tres")
const WALKABLE_GHOST_HOUSE := [
	Vector2i(14, 15), Vector2i(14, 16), Vector2i(14, 17), Vector2i(14, 18),
	Vector2i(-13, -17), Vector2i(13, 18), Vector2i(12, 17), Vector2i(12, 18),
	Vector2i(-15, -17), Vector2i(15, 18), Vector2i(16, 17), Vector2i(16, 18)
]
const TUNNEL_CELLS := [
	Vector2i(-2, 17), Vector2i(-1, 17), Vector2i(0, 17), Vector2i(1, 17), Vector2i(2, 17), Vector2i(3, 17), Vector2i(4, 17),
	Vector2i(23, 17), Vector2i(24, 17), Vector2i(25, 17), Vector2i(26, 17), Vector2i(27, 17), Vector2i(28, 17), Vector2i(29, 17),
]
var _tunnel_traveling := false

const GRID = preload("res://resources/Grid.tres")
var current_cell_coordinates : Vector2i
var _previous_cell_coordinates : Vector2i
var _current_cell_position : Vector2
var _desired_cell_coordinates : Vector2i
var _desired_cell_position : Vector2
var target_coordinates := Vector2i(14, 26)
var target_position : Vector2
@export var scatter_coordinates := Vector2i(25, 0)

var _in_front_of_ghost_house := [Vector2i(13, 14), Vector2i(14, 14)]
@export var _target_inside_the_house := Vector2i(14, 18)
var _house_exit_coordinates := Vector2i(14, 18)
var _adjust_the_grid := false
@export var is_inside_the_ghost_house := false
@export var locked_inside_the_ghost_house := false


@export var _direction := Vector2i.LEFT
var normal_speed := 1.0
var speed := 1.0

@export var sprite_frames : SpriteFrames
@export var ghost_color : Color = Color("RED", 0.6)

var _starting_position : Vector2
var _is_inside_the_ghost_house_on_start := false
var _starting_direction : Vector2i

enum State {
	TARGETING,
	FRIGHTENED,
	EATEN,
	LOCKED
}
var current_state := State.TARGETING

var _seed := "FRIGHTENED".hash()
var _fright_time := 6.0
var _is_frightened := false
var pacman_eaten := false

var _current_level : String
var personal_dot_counter := 0
var _personal_dot_number := -1
var personal_dot_count_reached := false
var _global_dot_counter_number := -1
var release := false : set = _set_on_ghost_release

func _ready() -> void:
	_current_level = GameState.current_level[GameState.current_level_counter]
	_individual_ghost_adjustments()
	
	_starting_setup()
	
	_fright_timer_setup()

func _individual_ghost_adjustments() -> void:
	animated_sprite_2d.sprite_frames = sprite_frames
	_starting_position = global_position
	_is_inside_the_ghost_house_on_start = is_inside_the_ghost_house
	_starting_direction = _direction
	
	if GameState.current_level_counter > 3:
		_personal_dot_number = 0
	else:
		match name:
			"Blinky":
				_personal_dot_number = GameState.personal_dot_number[_current_level][0]
			"Pinky":
				_personal_dot_number = GameState.personal_dot_number[_current_level][1]
				_global_dot_counter_number = 7
			"Inky":
				_personal_dot_number = GameState.personal_dot_number[_current_level][2]
				_global_dot_counter_number = 17
			"Clyde":
				_personal_dot_number = GameState.personal_dot_number[_current_level][3]
				_global_dot_counter_number = 32
	
	if personal_dot_counter == _personal_dot_number:
		release = true
		personal_dot_count_reached = true
	
	target_cell_panel.size = Vector2(8.0, 8.0)
	var stylebox = StyleBoxFlat.new()
	stylebox.bg_color = ghost_color
	#stylebox.border_width_bottom = 1
	#stylebox.border_width_left = 1
	#stylebox.border_width_right = 1
	#stylebox.border_width_top = 1
	#stylebox.border_color = Color(ghost_color, 1.0)
	target_cell_panel.add_theme_stylebox_override("panel", stylebox)
	
	add_child(target_cell_panel)
	add_child(desired_cell_position_panel)

func _starting_setup() -> void:
	if is_inside_the_ghost_house:
		_adjust_the_grid = true
		speed = normal_speed / 2.0
	if locked_inside_the_ghost_house:
		current_state = State.LOCKED
	seed(_seed)
	current_cell_coordinates = GRID.calculate_cell_coordinates(global_position, _adjust_the_grid)
	_current_cell_position = GRID.calculate_cell_position(current_cell_coordinates, _adjust_the_grid)
	
	target_cell_panel.position = Vector2.ZERO
	desired_cell_position_panel.position = Vector2.ZERO

	_calculate_next_desired_position()

func _physics_process(delta: float) -> void:
	
	if pacman_eaten:
		process_mode = Node.PROCESS_MODE_INHERIT
		return
	personal_dot_counter_label.text = str(personal_dot_counter)
	if personal_dot_counter == _personal_dot_number and GameState.global_dot_counter_active == false:
		release = true
		personal_dot_count_reached = true
	elif GameState.global_dot_count == _global_dot_counter_number:
		release = true
	
	current_cell_coordinates = GRID.calculate_cell_coordinates(global_position, _adjust_the_grid)
	_current_cell_position = GRID.calculate_cell_position(current_cell_coordinates, _adjust_the_grid)
	if TUNNEL_CELLS.has(current_cell_coordinates) and _tunnel_traveling == false and current_state == State.TARGETING:
		speed = normal_speed / 2.0
		_tunnel_traveling = true
	elif !TUNNEL_CELLS.has(current_cell_coordinates) and _tunnel_traveling == true and current_state == State.TARGETING:
		speed = normal_speed
		_tunnel_traveling = false
	
	if target_coordinates:
		target_position = GRID.calculate_cell_position(target_coordinates, _adjust_the_grid)
		target_cell_panel.global_position = target_position - Vector2(4.0, 4.0)
	desired_cell_position_panel.global_position = _desired_cell_position - Vector2(4.0, 4.0)
	
	if global_position == _desired_cell_position:
		_calculate_next_desired_position()
		if (
			current_state == State.TARGETING or 
			current_state == State.EATEN
		):
			if current_state == State.EATEN:
				process_mode = Node.PROCESS_MODE_ALWAYS
			_calculate_next_move()
		elif current_state == State.FRIGHTENED:
			_randomize_next_move()
		elif current_state == State.LOCKED:
			_locked_behaviour()
	
	_ghost_house_behaviour()
	
	if frightened_timer.time_left < 2.0 and !frightened_timer.is_stopped():
		animated_sprite_2d.animation = "frightened_flashing"
	
	_wrap_around_the_screen()
	
	global_position = global_position.move_toward(_desired_cell_position, 60.0 * delta * speed)

func _calculate_next_desired_position() -> void:
	_previous_cell_coordinates = current_cell_coordinates
	_desired_cell_coordinates = current_cell_coordinates + _direction
	_desired_cell_position = GRID.calculate_cell_position(_desired_cell_coordinates, _adjust_the_grid)
	desired_cell_position_panel.global_position = _desired_cell_position - Vector2(4.0, 4.0)

	if _check_walkability(_desired_cell_coordinates) == false:
		_desired_cell_position = _current_cell_position
	if current_state == State.FRIGHTENED or _is_frightened or GameState.player_ready_screen == true:
		return
	match_animation()

func _calculate_next_move() -> void:
	var possible_directions := [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	# Remove backward direction
	possible_directions.erase(- _direction)
	# Remove non-walkable directions
	for i in range(possible_directions.size()):
		var to_check_walkable : Vector2i = _desired_cell_coordinates + possible_directions[i]
		if _check_walkability(to_check_walkable) == false:
			possible_directions[i] = null
		if (
			current_cell_coordinates.y == 26 and
			(to_check_walkable == Vector2i(12, 25) or to_check_walkable == Vector2i(15, 25)) or
			current_cell_coordinates.y == 14 and
			(to_check_walkable == Vector2i(12, 13) or to_check_walkable == Vector2i(15, 13))
		):
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
		cell_pos = GRID.calculate_cell_position(_desired_cell_coordinates + dir, _adjust_the_grid)
		length_to_target.append((target_position - cell_pos).length())
	if possible_directions.is_empty():
		return
	_direction = possible_directions[0]
	if length_to_target.is_empty():
		return
	var min_length := length_to_target[0]
	for i in range(length_to_target.size()):
		if length_to_target[i] < min_length:
			min_length = length_to_target[i]
			_direction = possible_directions[i]

func _randomize_next_move() -> void:
	var possible_directions : Array[Vector2i]= [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	# Remove backward direction
	possible_directions.erase(- _direction)
	var chosen_direction : Vector2i = possible_directions.pick_random()
	if WALKABLE_CELLS.is_walkable(_desired_cell_coordinates + chosen_direction):
		_direction = chosen_direction
		return
	else:
		possible_directions.erase(chosen_direction)
	for dir in possible_directions:
		if WALKABLE_CELLS.is_walkable(_desired_cell_coordinates + dir):
			_direction = dir
			return

func match_animation() -> void:
	if (current_state == State.TARGETING or current_state == State.LOCKED) and !_is_frightened:
		match _direction:
			Vector2i.UP:
				animated_sprite_2d.play("up")
			Vector2i.LEFT:
				animated_sprite_2d.play("left")
			Vector2i.DOWN:
				animated_sprite_2d.play("down")
			Vector2i.RIGHT:
				animated_sprite_2d.play("right")
	if current_state == State.EATEN:
		animated_sprite_2d.animation = "eaten"
		match _direction:
			Vector2i.UP:
				animated_sprite_2d.frame = 0
			Vector2i.LEFT:
				animated_sprite_2d.frame = 1
			Vector2i.DOWN:
				animated_sprite_2d.frame = 2
			Vector2i.RIGHT:
				animated_sprite_2d.frame = 3

func _wrap_around_the_screen() -> void:
	if global_position.x <= GRID.calculate_cell_position(Vector2i(-2, 0)).x:
		current_cell_coordinates.x = (Vector2i(GRID.size) + Vector2i(1, 0)).x
		global_position.x = GRID.calculate_cell_position(current_cell_coordinates).x
		_calculate_next_desired_position()
	elif global_position.x >= GRID.calculate_cell_position(Vector2i(GRID.size) + Vector2i(1, 0)).x:
		current_cell_coordinates.x = Vector2i(-2, 0).x
		global_position.x = GRID.calculate_cell_position(current_cell_coordinates).x
		_calculate_next_desired_position()

func switch_direction() -> void:
	_direction = _previous_cell_coordinates - _desired_cell_coordinates
	_desired_cell_coordinates = _previous_cell_coordinates
	_calculate_next_move()
	_desired_cell_position = GRID.calculate_cell_position(_desired_cell_coordinates)

func frightened() -> void:
	if current_state == State.EATEN:
		return
	_is_frightened = true
	z_index = -1
	if current_state == State.LOCKED or is_inside_the_ghost_house:
		animated_sprite_2d.animation = "frightened"
		frightened_timer.start(_fright_time)
	if is_inside_the_ghost_house:
		return
	if _fright_time == 0.0:
		switch_direction()
		return
	current_state = State.FRIGHTENED
	animated_sprite_2d.animation = "frightened"
	speed = 0.5
	frightened_timer.start(_fright_time)
	switch_direction()

func _fright_timer_setup() -> void:
	if GameState.current_level_counter > 19:
		_fright_time = 0.0
	else:
		_fright_time = GameState.fright_time[_current_level]
	
	frightened_timer.timeout.connect(func() -> void:
		_is_frightened = false
		z_index = 0
		if current_state == State.LOCKED:
			return
		current_state = State.TARGETING
		match_animation()
		speed = 1.0
	)

func death() -> void:
	_is_frightened = false
	z_index = 0
	target_coordinates = _in_front_of_ghost_house[0]
	current_state = State.EATEN
	speed = 2.0
	frightened_timer.stop()
	match_animation()

func show_points(ghost_eaten_counter : int) -> void:
	animated_sprite_2d.play("points")
	match ghost_eaten_counter:
		1:
			animated_sprite_2d.frame = 1
		2:
			animated_sprite_2d.frame = 2
		3:
			animated_sprite_2d.frame = 3
		4:
			animated_sprite_2d.frame = 4

func _ghost_house_behaviour() -> void:
	
	if (
		(
			current_cell_coordinates == _in_front_of_ghost_house[0] or 
			current_cell_coordinates == _in_front_of_ghost_house[1]
		) 
		and current_state == State.EATEN and _adjust_the_grid == false
	):
		_desired_cell_position = GRID.calculate_cell_position(_in_front_of_ghost_house[0])
		_desired_cell_position.x += GRID.cell_size.x / 2.0
		_adjust_the_grid = true
		_direction = Vector2i.DOWN
		target_coordinates = _target_inside_the_house
	
	if current_state == State.EATEN and current_cell_coordinates == _target_inside_the_house:
		current_state = State.TARGETING
		process_mode = Node.PROCESS_MODE_INHERIT
		is_inside_the_ghost_house = true
		_desired_cell_position = GRID.calculate_cell_position(_house_exit_coordinates, _adjust_the_grid)
	if (
		current_state == State.TARGETING and 
		is_inside_the_ghost_house and
		_current_cell_position == _desired_cell_position
	):
		target_coordinates = _in_front_of_ghost_house[1]
		_direction = Vector2i.UP
		speed = 0.5
		if current_cell_coordinates == _in_front_of_ghost_house[1]:
			is_inside_the_ghost_house = false
			_adjust_the_grid = false
			_direction = Vector2i.LEFT
			_calculate_next_desired_position()
			if _is_frightened:
				current_state = State.FRIGHTENED
				return
			speed = 1.0

func _check_walkability(to_check_walkable: Vector2i) -> bool:
	return !(
			!WALKABLE_CELLS.is_walkable(to_check_walkable) and
			(
				!(current_state == State.EATEN) and 
				!(is_inside_the_ghost_house) or 
				!WALKABLE_GHOST_HOUSE.has(to_check_walkable)
			)
		)

func _locked_behaviour() -> void:
	_direction *= -1
	_calculate_next_desired_position()
	if release == true and current_cell_coordinates.y == _house_exit_coordinates.y:
		_desired_cell_position = GRID.calculate_cell_position(_house_exit_coordinates, _adjust_the_grid)
		_direction = (_desired_cell_position - _current_cell_position).sign()
		match_animation()
		current_state = State.TARGETING
	if _is_frightened:
		return
	match_animation()

func reset_position_on_pacman_death() -> void:
	visible = false
	animated_sprite_2d.play("default")
	global_position = _starting_position
	_direction = _starting_direction
	if _is_inside_the_ghost_house_on_start:
		is_inside_the_ghost_house = true
		locked_inside_the_ghost_house = true
		current_state = State.LOCKED
		release = false
	else:
		current_state = State.TARGETING
	if name == "Pinky":
		_direction = Vector2i.DOWN
	_starting_setup()

func _set_on_ghost_release(new_value : bool) -> void:
	release = new_value
	red_green_indicator.turn_green() if release else red_green_indicator.turn_red()
