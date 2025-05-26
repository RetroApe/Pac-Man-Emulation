class_name UI
extends Control

@onready var lives_indicator: LivesIndicator = %LivesIndicator
@onready var fruit_level_indicator: HBoxContainer = %FruitLevelIndicator

var _lives : int

func _process(_delta: float) -> void:
	if _lives < GameState.lives_remaining:
		_lives += 1
		lives_indicator.add_a_life()
	elif _lives > GameState.lives_remaining and _lives != 0:
		_lives -= 1
		print(_lives)
		lives_indicator.remove_a_life()

func set_up() -> void:
	_lives = GameState.lives_remaining
	lives_indicator.set_life_indicator()
	fruit_level_indicator.clear()
	fruit_level_indicator.set_up()

func clear_ui() -> void:
	fruit_level_indicator.clear()
