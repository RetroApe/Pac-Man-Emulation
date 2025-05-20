class_name Ghost
extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var target_cell_panel: Panel = %TargetCell
@onready var desired_cell_position_panel: Panel = %DesiredCellPositionPanel
@onready var target_cell_coordinates_label: Label = %TargetCellCoordinates
@onready var current_cell_coordinates_label: Label = %CurrentCellCoordinates
@onready var frightened_timer: Timer = %FrightenedTimer

const GRID = preload("res://resources/Grid.tres")
var current_cell_coordinates : Vector2i
var _previous_cell_coordinates : Vector2i
var _current_cell_position : Vector2
var _desired_cell_coordinates : Vector2i
var _desired_cell_position : Vector2
var target_coordinates := Vector2i(14, 26)
var target_position : Vector2
@export var _scatter_coordinates := Vector2i(25, 0)

var _in_front_of_ghost_house := [Vector2i(13, 14), Vector2i(14, 14)]
@export var _target_inside_the_house := Vector2i(14, 18)
var _adjust_the_grid := false
var is_inside_the_ghost_house := false

const WALKABLE_CELLS = preload("res://resources/WalkableCells.tres")
const WALKABLE_GHOST_HOUSE := [
	Vector2i(14, 15), Vector2i(14, 16), Vector2i(14, 17), Vector2i(14, 18),
	Vector2i(13, 17), Vector2i(13, 18), Vector2i(12, 17), Vector2i(12, 18),
	Vector2i(13, 17), Vector2i(13, 18), Vector2i(12, 17), Vector2i(12, 18),
	Vector2i(15, 17), Vector2i(15, 18), Vector2i(16, 17), Vector2i(16, 18)
]
const TUNNEL_CELLS := [
	Vector2i(-2, 17), Vector2i(-1, 17), Vector2i(0, 17), Vector2i(1, 17), Vector2i(2, 17), Vector2i(3, 17), Vector2i(4, 17),
	Vector2i(23, 17), Vector2i(24, 17), Vector2i(25, 17), Vector2i(26, 17), Vector2i(27, 17), Vector2i(28, 17), Vector2i(29, 17),
]
var _tunnel_traveling := false

var _direction := Vector2i.LEFT
var normal_speed := 1.0
var speed := 1.0

enum State {
	TARGETING,
	FRIGHTENED,
	EATEN
}
var current_state := State.TARGETING
var _seed := "FRIGHTENED".hash()
var _frightened_timing := 6.0

func _ready() -> void:
	seed(_seed)
	current_cell_coordinates = GRID.calculate_cell_coordinates(global_position)
	_current_cell_position = GRID.calculate_cell_position(current_cell_coordinates)
	animated_sprite_2d.play("left")
	_calculate_next_desired_position()
	
	frightened_timer.timeout.connect(func() -> void:
		current_state = State.TARGETING
		speed = 1.0
	)

func _physics_process(delta: float) -> void:
	current_cell_coordinates = GRID.calculate_cell_coordinates(global_position, _adjust_the_grid)
	_current_cell_position = GRID.calculate_cell_position(current_cell_coordinates, _adjust_the_grid)
	if TUNNEL_CELLS.has(current_cell_coordinates) and _tunnel_traveling == false:
		speed /= 2
		_tunnel_traveling = true
	elif !TUNNEL_CELLS.has(current_cell_coordinates) and _tunnel_traveling == true:
		speed = normal_speed
		_tunnel_traveling = false
	
	if target_coordinates:
		target_position = GRID.calculate_cell_position(target_coordinates, _adjust_the_grid)
		target_cell_panel.global_position = target_position - Vector2(4.0, 4.0)
		target_cell_coordinates_label.text = str(target_coordinates)
	current_cell_coordinates_label.text = str(current_cell_coordinates)
	desired_cell_position_panel.global_position = _desired_cell_position - Vector2(4.0, 4.0)
	
	if global_position == _desired_cell_position:
		_calculate_next_desired_position()
		if (
			current_state == State.TARGETING or 
			current_state == State.EATEN
		):
			_calculate_next_move()
		elif current_state == State.FRIGHTENED:
			_randomize_next_move()
	
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
	if current_state == State.FRIGHTENED:
		return
	_match_animation()

func _calculate_next_move() -> void:
	var possible_directions := [Vector2i.UP, Vector2i.LEFT, Vector2i.DOWN, Vector2i.RIGHT]
	# Remove backward direction
	possible_directions.erase(- _direction)
	# Remove non-walkable directions
	for i in range(possible_directions.size()):
		var to_check_walkable : Vector2i = _desired_cell_coordinates + possible_directions[i]
		if _check_walkability(to_check_walkable) == false:
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

func _match_animation() -> void:
	if current_state == State.TARGETING:
		match _direction:
			Vector2i.UP:
				animated_sprite_2d.animation = "up"
			Vector2i.LEFT:
				animated_sprite_2d.animation = "left"
			Vector2i.DOWN:
				animated_sprite_2d.animation = "down"
			Vector2i.RIGHT:
				animated_sprite_2d.animation = "right"
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
	if current_state == State.EATEN or is_inside_the_ghost_house:
		return
	current_state = State.FRIGHTENED
	animated_sprite_2d.animation = "frightened"
	speed = 0.5
	frightened_timer.start(_frightened_timing)
	if current_state == State.EATEN:
		return
	switch_direction()

func death() -> void:
	print("Ghost Eaten")
	target_coordinates = _in_front_of_ghost_house[0]
	current_state = State.EATEN
	speed = 2.0
	frightened_timer.stop()
	_match_animation()

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
		is_inside_the_ghost_house = true
		
	if current_state == State.TARGETING and is_inside_the_ghost_house:
		target_coordinates = _in_front_of_ghost_house[1]
		_direction = Vector2i.UP
		speed = 0.5
	if current_state == State.TARGETING and current_cell_coordinates == _in_front_of_ghost_house[1]:
		is_inside_the_ghost_house = false
		_adjust_the_grid = false
		_direction = Vector2i.LEFT
		speed = 1.0
		_calculate_next_desired_position()

func _check_walkability(to_check_walkable: Vector2i) -> bool:
	return !(
			!WALKABLE_CELLS.is_walkable(to_check_walkable) and
			(
				!(current_state == State.EATEN) and 
				!(is_inside_the_ghost_house) or 
				!WALKABLE_GHOST_HOUSE.has(to_check_walkable)
			)
		)
