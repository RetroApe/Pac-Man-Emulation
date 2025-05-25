extends Node2D

@onready var timer: Timer = %Timer
@onready var level: Level = %Level

const LEVEL = preload("res://scenes/level/level.tscn")

@export var make_pacman_invincible := false : set = _invincibility_change

func _ready() -> void:
	#timer.timeout.connect(func() -> void:
		#GameState.current_level_counter += 1
	#)
	GameState.is_pacman_invincible = make_pacman_invincible
	
	GameState.all_dots_eaten.connect(func() -> void:
		get_tree().paused = true
		level.execute_ending_sequence()
	)
	
	level.reset_the_level.connect(_level_reset)

func _level_reset() -> void:
	print("reseting the level")
	level.queue_free()
	get_tree().create_timer(0.3).timeout.connect(func() -> void:
		GameState.current_level_counter += 1
		GameState.dots_eaten = 0
		level = LEVEL.instantiate()
		add_child(level)
		level.reset_the_level.connect(_level_reset)
	)

func _invincibility_change(new_value : bool) -> void:
	make_pacman_invincible = new_value
	GameState.is_pacman_invincible = make_pacman_invincible
