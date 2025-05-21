extends Node2D

@onready var pac_man: PacMan = %PacMan
@onready var ghosts: Ghosts = %Ghosts
@onready var start_timer: Timer = %StartTimer

const GRID = preload("res://resources/Grid.tres")
const CELL = preload("res://cell.tscn")

func _ready() -> void:
	start_timer.timeout.connect(func() -> void:
		get_tree().paused = false
	)
	get_tree().paused = true
	
	for cell_coord in Ghost.WALKABLE_GHOST_HOUSE:
		var cell_panel : Panel = CELL.instantiate()
		cell_panel.position = GRID.calculate_cell_position(cell_coord, true) - Vector2(4.0, 4.0)
		add_child(cell_panel)
	
	pac_man.energizer_eaten.connect(_on_eaten_energizer)
	
	ghosts.pacman_dead.connect(pac_man.death)

func _process(_delta: float) -> void:
	ghosts.pacman_current_cell_coordinates = pac_man.current_cell_coordinates
	ghosts.pacman_direction = pac_man.direction

func _on_eaten_energizer() -> void:
	ghosts.frightened()
