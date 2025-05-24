extends Marker2D

const FRUIT = preload("res://scenes/fruit/fruit.tscn")

func spawn_fruit() -> void:
	var fruit = FRUIT.instantiate()
	call_deferred("add_child", fruit)
	#add_child(fruit)
	print("Fruit spawned")
