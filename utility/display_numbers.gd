class_name DisplayNumbers
extends Node2D

var _total_number_array : Array[Node]
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
	
	_total_number_array = get_children()
	display(1234)
	set_display_color(_color_dict[_text_color])
	

func display(number : int = 0):
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
			
		
func set_display_color(color : String = "milky"):
	print(color)
	for num in _total_number_array as Array[NumberDisplay]:
		num.set_color(color)
