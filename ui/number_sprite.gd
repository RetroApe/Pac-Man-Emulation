class_name NumberDisplay
extends AnimatedSprite2D

func set_color(color : String = "default") -> void:
	animation = color

func show_number(number : int) -> void:
	if number >= 0 and number <= 9:
		frame = number
	else:
		print("Not a single number or it is a negative number.")

func show_empty_frame() -> void:
	frame = 10
