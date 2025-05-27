extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

func stop_blinking() -> void:
	animated_sprite_2d.stop()

func start_blinking() -> void:
	animated_sprite_2d.play("default")
