class_name LivesIndicator
extends HBoxContainer

var _lives_array : Array[Node]

func _ready() -> void:
	_lives_array = get_children()

func remove_a_life() -> void:
	var life : TextureRect = _lives_array.pop_front()
	life.queue_free()

func add_a_life() -> void:
	var life := _lives_array[0].duplicate()
	add_child(life)
	_lives_array.append(life)
