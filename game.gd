extends Node2D

@onready var timer: Timer = %Timer
@onready var level: Level = %Level

const LEVEL = preload("res://scenes/level/level.tscn")

func _ready() -> void:
	#timer.timeout.connect(func() -> void:
		#GameState.current_level_counter += 1
	#)
	
	GameState.all_dots_eaten.connect(func() -> void:
		get_tree().paused = true
		level.execute_ending_sequence()
	)
	
	level.reset_the_level.connect(func() -> void:
		level.queue_free()
		GameState.current_level_counter += 1
		GameState.dots_eaten = 0
		level = LEVEL.instantiate()
		add_child(level)
	)
