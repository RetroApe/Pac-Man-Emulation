extends Panel

var _stylebox : StyleBoxFlat = StyleBoxFlat.new()

func _init() -> void:
	_stylebox.corner_radius_top_left = 2
	_stylebox.corner_radius_top_right = 2
	_stylebox.corner_radius_bottom_right = 2
	_stylebox.corner_radius_bottom_left = 2
	_stylebox.bg_color = Color.RED
	add_theme_stylebox_override("panel", _stylebox)

func turn_red() -> void:
	_stylebox.bg_color = Color.RED

func turn_green() -> void:
	_stylebox.bg_color = Color.WEB_GREEN
