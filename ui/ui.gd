extends Control

@onready var lives_indicator: LivesIndicator = %LivesIndicator
@onready var current_level: Label = %CurrentLevel

var _lives : int

func _ready() -> void:
	_lives = GameState.lives_remaining
	current_level.text = "Level\n" + str(GameState.current_level_counter)
	
	GameState.level_changed.connect(func() -> void:
		current_level.text = "Level\n" + str(GameState.current_level_counter)
	)

func _process(_delta: float) -> void:
	if _lives < GameState.lives_remaining:
		_lives += 1
		lives_indicator.add_a_life()
	elif _lives > GameState.lives_remaining and _lives != 0:
		_lives -= 1
		print(_lives)
		lives_indicator.remove_a_life()
