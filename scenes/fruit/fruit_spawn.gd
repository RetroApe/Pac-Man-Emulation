extends Marker2D

const FRUIT = preload("res://scenes/fruit/fruit.tscn")

func spawn_fruit() -> void:
	var fruit = FRUIT.instantiate()
	add_child(fruit)
