class_name Level
extends Node2D

signal reset_the_level

@onready var pacman: PacMan = %PacMan
@onready var ghosts: Ghosts = %Ghosts
@onready var start_timer: Timer = %StartTimer
@onready var tile_set: MyTiles = %TileSet
@onready var fruit_spawn: Marker2D = %FruitSpawn

const GRID = preload("res://resources/Grid.tres")
const CELL = preload("res://cell.tscn")

func _ready() -> void:
	start_timer.timeout.connect(_start_the_game)
	get_tree().paused = true
	GameState.player_ready_screen = true
	
	#for cell_coord in Ghost.WALKABLE_GHOST_HOUSE:
		#var cell_panel : Panel = CELL.instantiate()
		#cell_panel.position = GRID.calculate_cell_position(cell_coord, true) - Vector2(4.0, 4.0)
		#add_child(cell_panel)
	
	pacman.dot_eaten.connect(_on_eaten_dot)
	
	pacman.energizer_eaten.connect(_on_eaten_energizer)
	
	ghosts.ghost_eaten.connect(func(ghost_eaten_counter : int) -> void:
		pacman.visible = false
		match ghost_eaten_counter:
			1:
				_increase_score_by(200)
			2:
				_increase_score_by(400)
			3:
				_increase_score_by(800)
			4:
				_increase_score_by(1600)
	)
	ghosts.ghost_eaten_but_make_pacman_visible.connect(func() -> void:
		pacman.visible = true
	)
	
	ghosts.pacman_dead.connect(func() -> void:
		pacman.death()
		ghosts.on_pacman_dead()
	)
	pacman.death_animation_finished.connect(func() -> void:
		tile_set.toggle_dots_visibility()
		GameState.lives_remaining -= 1
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
	print("GAME START")
	get_tree().paused = false
	pacman.animated_sprite_2d.play("right")
	GameState.player_ready_screen = false
	ghosts.on_game_start()

func _process(_delta: float) -> void:
	ghosts.pacman_current_cell_coordinates = pacman.current_cell_coordinates
	ghosts.pacman_direction = pacman.direction

func _on_eaten_dot(new_dots: int) -> void:
	ghosts.pacman_dots_eaten = new_dots
	_fruit_spawn_check()
	_increase_score_by(10)

func _on_eaten_energizer() -> void:
	_fruit_spawn_check()
	ghosts.frightened()
	_increase_score_by(50)

func _increase_score_by(number : int) -> void:
	GameState.score += number

func _fruit_spawn_check() -> void:
	match GameState.dots_eaten:
		70, 170: 
			fruit_spawn.spawn_fruit()

func execute_ending_sequence() -> void:
	get_tree().create_timer(2.0).timeout.connect(func() -> void:
		ghosts.visible = false
		tile_set.flash_walls()
	)
	tile_set.on_flashing_finished.connect(func() -> void:
		reset_the_level.emit()
	)
