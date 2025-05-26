class_name LivesIndicator
extends HBoxContainer

const LIFE_TEXTURE = preload("res://ui/life_texture.tscn")

var _lives_array : Array[Node]

func remove_a_life() -> void:
	var life : TextureRect = _lives_array.pop_front()
	life.queue_free()

func add_a_life() -> void:
	var life := LIFE_TEXTURE.instantiate()
	add_child(life)
	_lives_array.append(life)

func set_life_indicator() -> void:
	for life in get_children():
		if !null:
			life.queue_free()
	
	for i in range(GameState.lives_remaining):
		var life = LIFE_TEXTURE.instantiate()
		_lives_array.append(life)
		add_child(life)
