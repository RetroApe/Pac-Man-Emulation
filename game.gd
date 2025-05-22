extends Node2D

@onready var pacman: PacMan = %PacMan
@onready var ghosts: Ghosts = %Ghosts
@onready var start_timer: Timer = %StartTimer
@onready var tile_set: Node2D = %TileSet

const GRID = preload("res://resources/Grid.tres")
const CELL = preload("res://cell.tscn")

func _ready() -> void:
	start_timer.timeout.connect(_start_the_game)
	get_tree().paused = true
	GameState.player_ready_screen = true
	
	for cell_coord in Ghost.WALKABLE_GHOST_HOUSE:
		var cell_panel : Panel = CELL.instantiate()
		cell_panel.position = GRID.calculate_cell_position(cell_coord, true) - Vector2(4.0, 4.0)
		add_child(cell_panel)
	
	pacman.dot_eaten.connect(_on_eaten_dot)
	
	pacman.energizer_eaten.connect(_on_eaten_energizer)
	
	ghosts.pacman_dead.connect(func() -> void:
		GameState.lives_remaining -= 1
		pacman.death()
		ghosts.on_pacman_dead()
	)
	
	pacman.death_animation_finished.connect(func() -> void:
		tile_set.toggle_dots_visibility()
		get_tree().create_timer(0.1).timeout.connect(func() -> void:
			get_tree().paused = true
			GameState.player_ready_screen = true
			tile_set.toggle_dots_visibility()
			ghosts.ready_the_ghosts()
			pacman.ready_the_pacman()
			start_timer.start()
		)
	)

func _start_the_game() -> void:
	get_tree().paused = false
	pacman.animated_sprite_2d.play("right")
	GameState.player_ready_screen = false
	ghosts.on_game_start()

func _process(_delta: float) -> void:
	ghosts.pacman_current_cell_coordinates = pacman.current_cell_coordinates
	ghosts.pacman_direction = pacman.direction

func _on_eaten_dot(new_dots: int) -> void:
	ghosts.pacman_dots_eaten = new_dots

func _on_eaten_energizer() -> void:
	ghosts.frightened()
