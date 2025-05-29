class_name Ghosts
extends Node2D

signal pacman_dead
signal ghost_eaten
signal ghost_eaten_but_make_pacman_visible
signal frightened_finished
signal ghost_exited_eaten_state

@onready var exit_timer: Timer = %ExitTimer
@onready var exit_display: DisplayNumbers = %ExitDisplay
@onready var global_count_display: DisplayNumbers = %GlobalCountDisplay
@onready var elroy_indicator: TileMapLayer = %ElroyIndicator
@onready var blinky_speed_display: DisplayNumbers = %BlinkySpeedDisplay
@onready var ghosts_speed_display: DisplayNumbers = %GhostsSpeedDisplay
@onready var ghost_eaten_sfx: AudioStreamPlayer2D = %GhostEatenSFX
@onready var eyes_sfx: AudioStreamPlayer2D = %EyesSFX
@onready var fright_sfx: AudioStreamPlayer2D = %FrightSFX

@onready var fright_timer: Timer = %FrightTimer
var _fright_time := 0.0

@onready var scatter_display: DisplayNumbers = %ScatterDisplay
@onready var chase_display: DisplayNumbers = %ChaseDisplay
@onready var scatter_chase_timer: Timer = %ScatterChaseTimer
var _scatter_chase_timing : Array
var _scatter_chase_timing_counter := GameState.scatter_chase_counter_start

enum {
	SCATTER,
	CHASE
}
var _current_state := SCATTER

var pacman_current_cell_coordinates : Vector2i
var pacman_direction : Vector2i
var pacman_dots_eaten := 0: set = set_dots
var _is_pacman_dead := false
var _is_pacman_set_to_die := false
var _ghosts_array : Array[Node]
var _current_level : String
var _blinky_coordinates : Vector2i
var _ghost_dot_counter_active := true
var _ghost_eaten_counter := 0
var _store_eaten_ghosts := 0
var _fright_in_process := false

func _ready() -> void:
	exit_display.visible = GameState.turn_on_exit_timer_display
	global_count_display.visible = GameState.turn_on_global_count_display
	chase_display.visible = GameState.turn_on_scatter_chase_display
	scatter_display.visible = GameState.turn_on_scatter_chase_display
	blinky_speed_display.visible = GameState.turn_on_speed_display
	ghosts_speed_display.visible = GameState.turn_on_speed_display
	elroy_indicator.visible = GameState.turn_on_elroy_display
	
	_current_level = GameState.current_level[GameState.current_level_counter] if GameState.current_level_counter < 21 else "level_21"
	_ghosts_array = find_children("*", "Ghost", false)
	
	_fright_time = GameState.fright_time[_current_level]
	fright_timer.wait_time = _fright_time if !is_zero_approx(_fright_time) else 111.0
	fright_timer.timeout.connect(func() -> void:
		scatter_chase_timer.paused = false
		frightened_finished.emit()
		fright_sfx.stop()
		_fright_in_process = false
	)
	
	for ghost in _ghosts_array as Array[Ghost]:
		ghost.ghost_exited_eaten_state.connect(func() -> void:
			_store_eaten_ghosts -= 1
			if _store_eaten_ghosts == 0:
				eyes_sfx.stop()
				ghost_exited_eaten_state.emit()
				if _fright_in_process == true:
					fright_sfx.play()
	)
	
	_exit_timer_setup()
	_scatter_chase_behaviour()
	if GameState.turn_on_target_display:
		_set_target_panels()

func _scatter_chase_behaviour() -> void:
	if GameState.current_level_counter > 5:
		_scatter_chase_timing = GameState.scatter_chase_timing["level_5"]
	else:
		_scatter_chase_timing = GameState.scatter_chase_timing[_current_level]
	
	_current_state = CHASE if _scatter_chase_timing_counter % 2 else SCATTER
	
	if _scatter_chase_timing_counter < 7:
		scatter_chase_timer.start(_scatter_chase_timing[_scatter_chase_timing_counter])
	scatter_chase_timer.timeout.connect(func() -> void:
		_scatter_chase_timing_counter += 1
		_current_state = CHASE if _scatter_chase_timing_counter % 2 else SCATTER
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

func _exit_timer_setup() -> void:
	if GameState.current_level_counter < 5:
		exit_timer.start(4.0)
	else:
		exit_timer.start(3.0)
	
	exit_timer.timeout.connect(func() -> void:
		for ghost in _ghosts_array as Array[Ghost]:
			if ghost.is_inside_the_ghost_house == true:
				ghost.release = true
				break
	)

func _process(_delta: float) -> void:
	if _fright_in_process == false:
		fright_sfx.stop()
	
	_scatter_chase_display()
	exit_display.display(int(ceil(exit_timer.time_left)))
	
	for ghost in _ghosts_array as Array[Ghost]:
		if ghost.name == "Blinky":
			blinky_speed_display.display(int(ghost.speed / 1.25 * 100))
		else:
			ghosts_speed_display.display(int(ghost.normal_speed / 1.25 * 100))
			if ghost.current_state == ghost.State.FRIGHTENED:
				ghosts_speed_display.display(int(ghost.speed / 1.25 * 100))
			break
	
	for ghost in _ghosts_array as Array[Ghost]:
		if ghost.name == "Blinky":
			_blinky_coordinates = ghost.current_cell_coordinates
			
			if ghost.elroy_state == ghost.Elroy.ONE:
				elroy_indicator.self_modulate.b = 0
			elif ghost.elroy_state == ghost.Elroy.TWO:
				elroy_indicator.self_modulate.g = 0
			
		if (
			ghost.current_state == ghost.State.TARGETING and 
			ghost.is_inside_the_ghost_house == false and
			(_current_state == CHASE or ghost.elroy_state != ghost.Elroy.OFF)
		):
			
			_assign_special_target(ghost)
			
		elif _current_state == SCATTER and ghost.current_state != ghost.State.EATEN and ghost.elroy_state == ghost.Elroy.OFF:
			ghost.target_coordinates = ghost.scatter_coordinates
	
		if ghost.current_cell_coordinates == pacman_current_cell_coordinates or _is_pacman_set_to_die == true:
			if (
				ghost.current_state == ghost.State.TARGETING 
				and _is_pacman_dead == false 
				and GameState.is_pacman_invincible == false
				or _is_pacman_set_to_die == true
			):
				pacman_dead.emit()
				_is_pacman_dead = true
				_is_pacman_set_to_die = false
			if (
				ghost.current_state == ghost.State.FRIGHTENED
			):
				_ghost_death_process(ghost)
				return

func _assign_special_target(ghost: Node2D) -> void:
	ghost = ghost as Ghost
	match ghost.name:
		"Blinky": 
			ghost.target_coordinates = pacman_current_cell_coordinates
		"Pinky":
			ghost.target_coordinates = pacman_current_cell_coordinates + 4 * pacman_direction
			if pacman_direction == Vector2i.UP and GameState.turn_on_pinky_target_correction == false:
				ghost.target_coordinates += Vector2i(-4, 0)
		"Inky":
			var intermediary := pacman_current_cell_coordinates + 2 * pacman_direction
			ghost.target_coordinates = 2 * intermediary - _blinky_coordinates
		"Clyde":
			var ghost_distance : float = (pacman_current_cell_coordinates - ghost.current_cell_coordinates).length()
			ghost_distance = floorf(ghost_distance)
			ghost.target_coordinates = pacman_current_cell_coordinates if ghost_distance > 8.0 else ghost.scatter_coordinates

func frightened() -> void:
	_fright_in_process = true
	fright_sfx.play()
	_ghost_eaten_counter = 0
	if !is_zero_approx(_fright_time):
		scatter_chase_timer.paused = true
		fright_timer.start()
	for ghost in _ghosts_array:
		ghost.frightened()
		#if ghost.current_cell_coordinates == pacman_current_cell_coordinates:
			#ghost.death()

func set_dots(new_dots: int) -> void:
	pacman_dots_eaten = new_dots
	exit_timer.start()
	if _ghost_dot_counter_active == true:
		for ghost in _ghosts_array as Array[Ghost]:
			if ghost.personal_dot_count_reached == false and ghost.is_inside_the_ghost_house:
				ghost = ghost as Ghost
				ghost.personal_dot_counter += 1
				break
	if GameState.global_dot_counter_active == true:
		GameState.global_dot_count +=1
		global_count_display.display(GameState.global_dot_count)
		# _ghosts_array[-1] refers to Clyde, assuming he is the last in the array,
		# which he is, since I put him there
		if GameState.global_dot_count == 32 and _ghosts_array[-1].is_inside_the_ghost_house == true:
			GameState.global_dot_counter_active = false

func on_pacman_dead() -> void:
	eyes_sfx.stop()
	fright_sfx.stop()
	scatter_chase_timer.paused = true
	fright_timer.stop()
	for ghost in _ghosts_array as Array[Ghost]:
		ghost.pacman_eaten = true
		get_tree().create_timer(1.0).timeout.connect(func() -> void:
			ghost.reset_position_on_pacman_death()
		)
	GameState.global_dot_counter_active = true
	GameState.global_dot_count = 0
	_ghost_dot_counter_active = false
	exit_timer.paused = true

func _ghost_death_process(ghost : Ghost) -> void:
	_store_eaten_ghosts += 1
	eyes_sfx.stop()
	ghost_eaten_sfx.play()
	fright_sfx.stop()
	get_tree().paused = true
	ghost.set_physics_process(false)
	ghost.death()
	_ghost_eaten_counter += 1
	if _ghost_eaten_counter == 4:
		_fright_in_process = false
	ghost_eaten.emit(_ghost_eaten_counter)
	ghost.show_points(_ghost_eaten_counter)
	get_tree().create_timer(1.0).timeout.connect(func() -> void:
		get_tree().paused = false
		ghost_eaten_but_make_pacman_visible.emit()
		ghost.match_animation()
		ghost.set_physics_process(true)
		eyes_sfx.play()
	)

func on_game_start() -> void:
	_is_pacman_dead = false
	exit_timer.start()
	exit_timer.paused = false
	
	_scatter_chase_timing_counter = GameState.scatter_chase_counter_start
	_current_state = CHASE if _scatter_chase_timing_counter % 2 else SCATTER
	scatter_chase_timer.paused = false
	if _scatter_chase_timing_counter < 7:
		scatter_chase_timer.start(_scatter_chase_timing[_scatter_chase_timing_counter])
	for ghost in _ghosts_array as Array[Ghost]:
		ghost.match_animation()

func ready_the_ghosts() -> void:
	for ghost in _ghosts_array as Array[Ghost]:
		ghost.visible = true
		ghost.pacman_eaten = false

func _set_target_panels() -> void:
	for ghost in _ghosts_array as Array[Ghost]:
		var target_panel = Panel.new()
		target_panel.name = ghost.name + "Panel"
		target_panel.size = Vector2(8.0, 8.0)
		target_panel.show_behind_parent = true
		add_child(target_panel)
		var stylebox = StyleBoxFlat.new()
		stylebox.bg_color = ghost.ghost_color
		stylebox.set_corner_radius_all(2)
		target_panel.add_theme_stylebox_override("panel", stylebox)
		ghost.target_cell_position_updated.connect(func(target_position : Vector2) -> void:
			target_panel.position = target_position
		)

func die_pacman_die() -> void:
	_is_pacman_set_to_die = true

func _scatter_chase_display() -> void:
	if scatter_chase_timer.is_stopped():
		chase_display.display_infinite()
		return
	if _current_state == CHASE:
		scatter_display.display_not_counting()
		chase_display.display(int(ceil(scatter_chase_timer.time_left)))
	elif _current_state == SCATTER :
		chase_display.display_not_counting()
		scatter_display.display(int(ceil(scatter_chase_timer.time_left)))
