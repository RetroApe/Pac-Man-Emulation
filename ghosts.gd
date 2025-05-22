class_name Ghosts
extends Node2D

signal pacman_dead

@onready var dots_eaten: Label = %DotsEaten

@onready var scatter_chase_timer: Timer = %ScatterChaseTimer
var _scatter_chase_timing : Array
var _scatter_chase_timing_counter := 0
enum {
	SCATTER,
	CHASE
}
var _current_state := SCATTER

var pacman_current_cell_coordinates : Vector2i
var pacman_direction : Vector2i
var pacman_dots_eaten := 0: set = set_dots
var _is_pacman_dead := false
var _ghosts_array : Array[Node]
var _current_level : String
var _blinky_coordinates : Vector2i
var _ghost_dot_counter_active := true

func _ready() -> void:
	_current_level = GameState.current_level[GameState.current_level_counter]
	_ghosts_array = find_children("*", "Ghost", false)
	
	_scatter_chase_behaviour()

func _process(_delta: float) -> void:
	for ghost in _ghosts_array:
		if ghost.name == "Blinky":
			_blinky_coordinates = ghost.current_cell_coordinates
		if (
			ghost.current_state == ghost.State.TARGETING and 
			ghost.is_inside_the_ghost_house == false and
			_current_state == CHASE
		):
			
			_assign_special_target(ghost)
			
		elif _current_state == SCATTER and ghost.current_state != ghost.State.EATEN:
			ghost.target_coordinates = ghost.scatter_coordinates
	
		if ghost.current_cell_coordinates == pacman_current_cell_coordinates:
			if ghost.current_state == ghost.State.TARGETING and _is_pacman_dead == false:
				pacman_dead.emit()
				_is_pacman_dead = true
			if ghost.current_state == ghost.State.FRIGHTENED:
				ghost.death()
				get_tree().paused = true
				get_tree().create_timer(1.0).timeout.connect(func() -> void:
					get_tree().paused = false
				)

func _assign_special_target(ghost: Node2D) -> void:
	ghost = ghost as Ghost
	match ghost.name:
		"Blinky": 
			ghost.target_coordinates = pacman_current_cell_coordinates
		"Pinky":
			ghost.target_coordinates = pacman_current_cell_coordinates + 4 * pacman_direction
			if pacman_direction == Vector2i.UP:
				ghost.target_coordinates += Vector2i(-4, 0)
		"Inky":
			var intermediary := pacman_current_cell_coordinates + 2 * pacman_direction
			ghost.target_coordinates = 2 * intermediary - _blinky_coordinates
		"Clyde":
			var ghost_distance : float = (pacman_current_cell_coordinates - ghost.current_cell_coordinates).length()
			ghost_distance = floorf(ghost_distance)
			ghost.target_coordinates = pacman_current_cell_coordinates if ghost_distance > 8.0 else ghost.scatter_coordinates

func _scatter_chase_behaviour() -> void:
	if GameState.current_level_counter > 5:
		_scatter_chase_timing = GameState.scatter_chase_timing["level_5"]
	else:
		_scatter_chase_timing = GameState.scatter_chase_timing[_current_level]
	
	scatter_chase_timer.start(_scatter_chase_timing[0])
	scatter_chase_timer.timeout.connect(func() -> void:
		_scatter_chase_timing_counter += 1
		_current_state = _scatter_chase_timing_counter % 2
		for ghost in _ghosts_array:
			if (
				ghost.is_inside_the_ghost_house == false and 
				(ghost.current_state == ghost.State.TARGETING or ghost.current_state == ghost.State.EATEN)
			):
				ghost.switch_direction()
		var time : float = _scatter_chase_timing[_scatter_chase_timing_counter]
		if time != -1.0:
			scatter_chase_timer.start(time)
		else:
			scatter_chase_timer.stop()
	)

func frightened() -> void:
	for ghost in _ghosts_array:
		ghost.frightened()
		if ghost.current_cell_coordinates == pacman_current_cell_coordinates:
			ghost.death()

func set_dots(new_dots: int) -> void:
	pacman_dots_eaten = new_dots
	dots_eaten.text = str(pacman_dots_eaten)
	if _ghost_dot_counter_active:
		for ghost in _ghosts_array:
			if ghost.release == false:
				ghost = ghost as Ghost
				ghost.personal_dot_counter += 1
				break

func on_pacman_dead() -> void:
	for ghost in _ghosts_array as Array[Ghost]:
		ghost.pacman_eaten = true
		get_tree().create_timer(1.0).timeout.connect(func() -> void:
			ghost.reset_position_on_pacman_death()
		)

func on_game_start() -> void:
	_is_pacman_dead = false
	for ghost in _ghosts_array as Array[Ghost]:
		ghost._match_animation()

func ready_the_ghosts() -> void:
	for ghost in _ghosts_array as Array[Ghost]:
		ghost.visible = true
		ghost.pacman_eaten = false
