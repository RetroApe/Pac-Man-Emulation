extends Node2D

@onready var ui: UI = %UI

var level: Level

const LEVEL = preload("res://scenes/level/level.tscn")

var _pacman_set_to_die := false
var _level_set_to_increase := false
var _pacmaning_in_progress := false

@export var make_pacman_invincible := false : set = _invincibility_change
@export_range(0, 4) var starting_lives := 4
@export var starting_eaten_dots := 0
@export_range(1, 256) var starting_level := 1
@export_range(0, 7) var scatter_chase_count := 0

func _ready() -> void:
	GameState.is_pacman_invincible = make_pacman_invincible
	GameState.all_dots_eaten.connect(func() -> void:
		_initiate_level_increase()
	)
	GameState.no_lives_left.connect(_on_game_over)
	

func _make_level() -> void:
	ui.set_up()
	level = LEVEL.instantiate()
	add_child(level)
	level.name = "Level"
	level.reset_the_level.connect(_level_reset)
	GameState.dots_eaten = starting_eaten_dots
	_pacman_set_to_die = false
	_level_set_to_increase = false

func _initiate_level_increase() -> void:
	get_tree().paused = true
	level.execute_ending_sequence()

func _level_reset() -> void:
	print("reseting the level")
	level.queue_free()
	get_tree().create_timer(0.3).timeout.connect(func() -> void:
		GameState.current_level_counter += 1
		GameState.dots_eaten = starting_eaten_dots
		_make_level()
	)

func _invincibility_change(new_value : bool) -> void:
	make_pacman_invincible = new_value
	GameState.is_pacman_invincible = make_pacman_invincible

func _on_game_over() -> void:
	get_tree().create_timer(2.0).timeout.connect(func() -> void:
		GameState.current_level_counter = 1
		level.queue_free()
		ui.clear_ui()
		_pacmaning_in_progress = false
	)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("level_start"):
		if level:
			print("Level found")
		elif _pacmaning_in_progress == false:
			GameState.global_dot_counter_active = false
			GameState.global_dot_count = 0
			GameState.lives_remaining = starting_lives
			GameState.current_level_counter = starting_level
			GameState.dots_eaten = starting_eaten_dots
			GameState.scatter_chase_counter_start = scatter_chase_count
			_make_level()
			_pacmaning_in_progress = true
	if event.is_action_pressed("kill_pacman") and level != null and _pacman_set_to_die == false:
		print("Die Pac-Man, die!")
		_pacman_set_to_die = true
		level.die_pacman_die()
	if event.is_action_pressed("level_increase") and _level_set_to_increase == false:
		_initiate_level_increase()
		_level_set_to_increase = true
	
