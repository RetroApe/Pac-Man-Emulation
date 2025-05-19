extends Node2D

@onready var pac_man: PacMan = %PacMan
@onready var ghost: Ghost = %Ghost

const GRID = preload("res://resources/Grid.tres")

var _scatter_chase_timing : Dictionary = {
	"level_1": [7.0, 20.0, 7.0, 20.0, 5.0, 20.0, 5.0, -1.0]
}


func _ready() -> void:
	pac_man.energizer_eaten.connect(_on_eaten_energizer)


func _process(_delta: float) -> void:
	ghost.target_coordinates = pac_man.current_cell_coordinates
	if ghost.current_cell_coordinates == pac_man.current_cell_coordinates:
		if ghost.current_state == ghost.State.TARGETING:
			pac_man.death()
		if ghost.current_state == ghost.State.FRIGHTENED:
			ghost.death()
	

func _on_eaten_energizer() -> void:
	ghost.frightened()
