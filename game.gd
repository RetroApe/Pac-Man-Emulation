extends Node2D

@onready var timer: Timer = %Timer

#func _ready() -> void:
	#timer.timeout.connect(func() -> void:
		#GameState.current_level_counter += 1
	#)
