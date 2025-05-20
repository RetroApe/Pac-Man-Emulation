extends Node2D

@onready var pac_man: PacMan = %PacMan
@onready var ghosts: Ghosts = %Ghosts
@onready var ghost: Ghost = %Ghost

const GRID = preload("res://resources/Grid.tres")

func _ready() -> void:
	pac_man.energizer_eaten.connect(_on_eaten_energizer)
	
	ghosts.pacman_dead.connect(pac_man.death)

func _process(_delta: float) -> void:
	ghosts.pacman_current_cell_coordinates = pac_man.current_cell_coordinates
	

func _on_eaten_energizer() -> void:
	ghosts.frightened()
