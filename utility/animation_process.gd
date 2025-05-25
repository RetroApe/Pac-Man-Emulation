extends AnimatedSprite2D

func _ready() -> void:
	GameState.no_lives_left.connect(func() -> void:
		stop()
		frame = 0
	)

func _process(_delta: float) -> void:
	if GameState.player_ready_screen == true:
		process_mode = Node.PROCESS_MODE_PAUSABLE
	elif GameState.player_ready_screen == false:
		process_mode = Node.PROCESS_MODE_ALWAYS
