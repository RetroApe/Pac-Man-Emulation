extends Node2D

@onready var animation: AnimationPlayer = %Animation

func _ready() -> void:
	animation.play("RESET")

func play_intro_animation() -> void:
	animation.play("entrance")

func stop_animation() -> void:
	animation.play("RESET")
