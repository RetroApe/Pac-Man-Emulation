class_name DisplayNumbers
extends Node2D

var _total_number_array : Array[Node]
@onready var inf: TileMapLayer = %INF
@onready var not_counting: Sprite2D = %NotCounting

@export var _pad_zeros := true
@export var _text_color : TextColor = TextColor.DEFAULT

enum TextColor {
	DEFAULT,
	RED,
	MILKY
}

var _color_dict := {
	TextColor.DEFAULT: "default",
	TextColor.RED: "red",
	TextColor.MILKY: "milky"
}

func _ready() -> void:
	_total_number_array = find_children("*", "NumberDisplay")
	set_display_color(_color_dict[_text_color])
	

func display(number : int = 0):
	not_counting.visible = false
	inf.visible = false
	var first_non_zero_reached = false
	var number_string := str(number).pad_zeros(4)
	for i in range(_total_number_array.size()):
		_total_number_array[i].show_number(int(number_string[i]))
		if _pad_zeros == false and first_non_zero_reached == false:
			if number_string[i] == "0":
				_total_number_array[i].visible = false
			else:
				first_non_zero_reached = true
				_total_number_array[i].visible = true
		else:
			_total_number_array[i].visible = true
	_total_number_array[_total_number_array.size() - 1].visible = true

func set_display_color(color : String = "milky"):
	for num in _total_number_array as Array[NumberDisplay]:
		num.set_color(color)

func display_not_counting() -> void:
	_hide_numbers()
	inf.visible = false
	not_counting.visible = true

func display_infinite() -> void:
	_hide_numbers()
	not_counting.visible = false
	inf.visible = true

func _hide_numbers() -> void:
	for num in _total_number_array:
		num.visible = false
