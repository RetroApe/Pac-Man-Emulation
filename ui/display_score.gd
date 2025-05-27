extends HBoxContainer

@onready var _6_number: NumberDisplay = %"6Number"
@onready var _5_number: NumberDisplay = %"5Number"
@onready var _4_number: NumberDisplay = %"4Number"
@onready var _3_number: NumberDisplay = %"3Number"
@onready var _2_number: NumberDisplay = %"2Number"
@onready var _1_number: NumberDisplay = %"1Number"

const TOTAL_NUMBERS := 6
var _current_number_displayed := 0

func _ready() -> void:
	set_text_color("milky")
	
	display_reset()
	
	GameState.score_changed.connect(func() -> void:
		match name:
			"Score":
				display(GameState.score)
			"HighScore":
				display(GameState.highscore)
	)


func set_text_color(color : String = "default") -> void:
	for display_number in get_children() as Array[NumberDisplay]:
		display_number.set_color(color)

func display(number : int) -> void:
	number %= 1000000
	if number < _current_number_displayed:
		return
	_current_number_displayed = number
	var number_to_check := str(number)
	var number_positions := number_to_check.length()
	for i in range(number_positions):
		var num = int(number_to_check[number_positions - 1 - i])
		match i + 1:
			6:
				_6_number.show_number(num)
			5:
				_5_number.show_number(num)
			4:
				_4_number.show_number(num)
			3:
				_3_number.show_number(num)
			2:
				_2_number.show_number(num)
			1:
				_1_number.show_number(num)

func display_reset() -> void:
	if GameState.score > 0:
		return
	_current_number_displayed = 0
	_6_number.show_empty_frame()
	_5_number.show_empty_frame()
	_4_number.show_empty_frame()
	_3_number.show_empty_frame()
	_2_number.show_number(0)
	_1_number.show_number(0)
