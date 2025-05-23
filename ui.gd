extends Control

@onready var lives_indicator: LivesIndicator = %LivesIndicator

var _lives : int

func _ready() -> void:
	_lives = GameState.lives_remaining

func _process(delta: float) -> void:
	if _lives < GameState.lives_remaining:
		_lives += 1
		lives_indicator.add_a_life()
	elif _lives > GameState.lives_remaining and _lives != 0:
		_lives -= 1
		print(_lives)
		lives_indicator.remove_a_life()
