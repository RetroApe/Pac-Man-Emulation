class_name UI
extends Control

@onready var score: HBoxContainer = %Score
@onready var high_score: HBoxContainer = %HighScore
@onready var lives_indicator: LivesIndicator = %LivesIndicator
@onready var fruit_level_indicator: HBoxContainer = %FruitLevelIndicator
@onready var _1up_text: Blinker = %"1UPText"
@onready var _2up_text: TileMapLayer = %"2UPText"

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
	high_score.visible = true
	_lives = GameState.lives_remaining
	lives_indicator.set_life_indicator()
	fruit_level_indicator.clear()
	fruit_level_indicator.set_up()
	_1up_text.please_proceed_to_blink()
	_2up_text.visible = false
	score.display_reset()

func clear_ui() -> void:
	fruit_level_indicator.clear()
	lives_indicator.clear()
	_1up_text.stop_with_all_this_blinking_pretty_please()
	_2up_text.visible = true
