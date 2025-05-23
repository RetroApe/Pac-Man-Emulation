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
	GameState.score_changed.connect(func() -> void:
		display(GameState.score)
	)

func set_text_color(color : String = "default") -> void:
	for display in get_children() as Array[NumberDisplay]:
		display.set_color(color)

func display(number : int) -> void:
	number %= 1000000
	if number < _current_number_displayed:
		return
	_current_number_displayed = number
	var number_to_check := str(number).pad_zeros(TOTAL_NUMBERS)
	for i in range(number_to_check.length()):
		var num = int(number_to_check[i])
		match 6 - i:
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
