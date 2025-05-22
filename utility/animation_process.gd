extends AnimatedSprite2D


func _process(_delta: float) -> void:
	if GameState.player_ready_screen == true:
		process_mode = Node.PROCESS_MODE_INHERIT
	elif GameState.player_ready_screen == false:
		process_mode = Node.PROCESS_MODE_ALWAYS
