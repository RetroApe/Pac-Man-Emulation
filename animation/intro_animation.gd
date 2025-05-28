extends Node2D

signal intro_animation_finished

@onready var animation: AnimationPlayer = %Animation

func _ready() -> void:
	animation.play("RESET")
	animation.animation_finished.connect(_on_animation_finished)

func play_intro_animation() -> void:
	#animation.play_section("entrance", 20.0)
	animation.play("entrance")

func stop_animation() -> void:
	animation.play("RESET")

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "RESET":
		return
	intro_animation_finished.emit()
	animation.play("RESET")
