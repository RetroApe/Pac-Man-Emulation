class_name Ghosts
extends Node2D

signal pacman_dead

@onready var blinky : Ghost = %Blinky
@onready var scatter_chase_timer: Timer = %ScatterChaseTimer

enum {
	SCATTER,
	CHASE
}
var _current_state := SCATTER

var pacman_current_cell_coordinates : Vector2i
var _ghosts_array : Array[Node]
var _current_level : String

func _ready() -> void:
	_current_level = EventBus.current_level[EventBus.current_level_counter]
	
	_ghosts_array = get_children()
	for each in _ghosts_array:
		if each.is_class("Node2D"):
			continue
		_ghosts_array.erase(each)
	
	scatter_chase_timer.start(EventBus.scatter_chase_timing[_current_level][0])
	scatter_chase_timer.timeout.connect(func() -> void:
		EventBus.scatter_chase_timing_counter += 1
		
		_current_state = EventBus.scatter_chase_timing_counter % 2
		#print(_current_state, " = ", EventBus.scatter_chase_timing_counter)
		for each in _ghosts_array:
			if each.is_inside_the_ghost_house == false and each.current_state == each.State.TARGETING:
				each.switch_direction()
		var time : float = EventBus.scatter_chase_timing[_current_level][EventBus.scatter_chase_timing_counter]
		if time != -1.0:
			#print("Time: ", time)
			scatter_chase_timer.start(time)
		else:
			scatter_chase_timer.stop()
	)

func _process(_delta: float) -> void:
	if (
		blinky.current_state == blinky.State.TARGETING and 
		blinky.is_inside_the_ghost_house == false and
		_current_state == CHASE
	):
		blinky.target_coordinates = pacman_current_cell_coordinates
	elif _current_state == SCATTER and blinky.current_state != blinky.State.EATEN:
		blinky.target_coordinates = blinky._scatter_coordinates
	
	for each in _ghosts_array:
		if each.current_cell_coordinates == pacman_current_cell_coordinates:
			if each.current_state == each.State.TARGETING:
				pacman_dead.emit()
			if each.current_state == each.State.FRIGHTENED:
				each.death()

func frightened() -> void:
	for ghostee in _ghosts_array:
		ghostee.frightened()
