extends Node2D

@onready var pac_man: PacMan = %PacMan
@onready var ghost: Ghost = %Ghost

func _process(_delta: float) -> void:
	ghost.target_coordinates = pac_man.current_cell_coordinates
