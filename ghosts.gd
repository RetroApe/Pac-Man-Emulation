class_name Ghosts
extends Node2D

signal pacman_dead

@onready var scatter_chase_timer: Timer = %ScatterChaseTimer

enum {
	SCATTER,
	CHASE
}
var _current_state := SCATTER

var pacman_current_cell_coordinates : Vector2i
var pacman_direction : Vector2i
var _ghosts_array : Array[Node]
var _current_level : String
var _blinky_coordinates : Vector2i

func _ready() -> void:
	_current_level = EventBus.current_level[EventBus.current_level_counter]
	
	_ghosts_array = find_children("*", "Ghost", false)
	
	scatter_chase_timer.start(EventBus.scatter_chase_timing[_current_level][0])
	scatter_chase_timer.timeout.connect(func() -> void:
		EventBus.scatter_chase_timing_counter += 1
		
		_current_state = EventBus.scatter_chase_timing_counter % 2
		#print(_current_state, " = ", EventBus.scatter_chase_timing_counter)
		for ghost in _ghosts_array:
			if (
				ghost.is_inside_the_ghost_house == false and 
				(ghost.current_state == ghost.State.TARGETING or ghost.current_state == ghost.State.EATEN)
			):
				ghost.switch_direction()
		var time : float = EventBus.scatter_chase_timing[_current_level][EventBus.scatter_chase_timing_counter]
		if time != -1.0:
			#print("Time: ", time)
			scatter_chase_timer.start(time)
		else:
			scatter_chase_timer.stop()
	)

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
			if ghost.current_state == ghost.State.TARGETING:
				pacman_dead.emit()
			if ghost.current_state == ghost.State.FRIGHTENED:
				ghost.death()

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
			print(ghost_distance)
			ghost.target_coordinates = pacman_current_cell_coordinates if ghost_distance > 8.0 else ghost.scatter_coordinates

func frightened() -> void:
	for ghost in _ghosts_array:
		ghost.frightened()
		if ghost.current_cell_coordinates == pacman_current_cell_coordinates:
			ghost.death()
