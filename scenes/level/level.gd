class_name Level
extends Node2D

signal reset_the_level
signal level_started_after_pacman_death

@onready var pacman: PacMan = %PacMan
@onready var ghosts: Ghosts = %Ghosts
@onready var start_timer: Timer = %StartTimer
@onready var tile_set: MyTiles = %TileSet
@onready var fruit_spawn: Marker2D = %FruitSpawn
@onready var player_one: TileMapLayer = %PlayerOne
@onready var ready_letters: TileMapLayer = %ReadyLetters
@onready var game_over_letters: TileMapLayer = %GameOverLetters
@onready var display_numbers: DisplayNumbers = $DisplayNumbers
@onready var siren_sfx: AudioStreamPlayer2D = %SirenSFX
@onready var start_game_sfx: AudioStreamPlayer2D = %StartGameSFX

const SIREN_0 = preload("res://assets/sounds/siren0.wav")
const SIREN_1 = preload("res://assets/sounds/siren1.wav")
const SIREN_2 = preload("res://assets/sounds/siren2.wav")
const SIREN_3 = preload("res://assets/sounds/siren3.wav")
const SIREN_4 = preload("res://assets/sounds/siren4.wav")
const GRID = preload("res://resources/Grid.tres")
const CELL = preload("res://cell.tscn")

var _fright_in_process := false
var _ready_screen_padding := 0.1

func _ready() -> void:
	siren_sfx.stream = SIREN_0
	display_numbers.visible = GameState.turn_on_level_display
	display_numbers.display(GameState.current_level_counter)
	start_timer.timeout.connect(_start_the_game)
	get_tree().paused = true
	GameState.player_ready_screen = true
	ready_letters.visible = true
	
	if GameState.score == 0:
		player_one.visible = true
		start_timer.start(start_game_sfx.stream.get_length())
		_ready_screen_padding = 2.0
		start_game_sfx.play()
	
	pacman.visible = false
	ghosts.visible = false
	tile_set.toggle_dots_visibility()
	get_tree().create_timer(0.1).timeout.connect(func() -> void:
		tile_set.toggle_dots_visibility()
	)
	get_tree().create_timer(_ready_screen_padding).timeout.connect(func() -> void:
		pacman.visible = true
		ghosts.visible = true
		player_one.visible = false
	)
	
	pacman.dot_eaten.connect(_on_eaten_dot)
	
	pacman.energizer_eaten.connect(_on_eaten_energizer)
	
	ghosts.ghost_eaten.connect(func(ghost_eaten_counter : int) -> void:
		siren_sfx.stop()
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
	ghosts.ghost_exited_eaten_state.connect(func() -> void:
		pass
	)
	ghosts.frightened_finished.connect(func() -> void:
		pacman.on_frightened_finished()
		siren_sfx.play()
		_fright_in_process = false
	)
	
	ghosts.pacman_dead.connect(func() -> void:
		pacman.death()
		ghosts.on_pacman_dead()
	)
	pacman.death_animation_finished.connect(func() -> void:
		GameState.lives_remaining -= 1
		if GameState.lives_remaining < 0:
			return
		tile_set.toggle_dots_visibility()
		get_tree().create_timer(0.1).timeout.connect(func() -> void:
			get_tree().paused = true
			GameState.player_ready_screen = true
			tile_set.toggle_dots_visibility()
			ghosts.ready_the_ghosts()
			pacman.ready_the_pacman()
			start_timer.start()
			ready_letters.visible = true
		)
	)
	
	GameState.no_lives_left.connect(_execute_game_over)

func _start_the_game() -> void:
	print("GAME START")
	siren_sfx.play()
	get_tree().paused = false
	pacman.animated_sprite_2d.play("right")
	GameState.player_ready_screen = false
	ghosts.on_game_start()
	ready_letters.visible = false
	level_started_after_pacman_death.emit()

func _process(_delta: float) -> void:
	ghosts.pacman_current_cell_coordinates = pacman.current_cell_coordinates
	ghosts.pacman_direction = pacman.direction

func _on_eaten_dot(new_dots: int) -> void:
	ghosts.pacman_dots_eaten = new_dots
	_dot_count_check()
	_increase_score_by(10)

func _on_eaten_energizer() -> void:
	_dot_count_check()
	siren_sfx.play()
	_fright_in_process = true
	ghosts.frightened()
	_increase_score_by(50)

func _increase_score_by(number : int) -> void:
	GameState.score += number

func _dot_count_check() -> void:
	match GameState.dots_eaten:
		70, 170: 
			fruit_spawn.spawn_fruit()
	match 244 - GameState.dots_eaten:
		120:
			siren_sfx.stream = SIREN_1
			if _fright_in_process == false:
				siren_sfx.play()
		60:
			siren_sfx.stream = SIREN_2
			if _fright_in_process == false:
				siren_sfx.play()
		30:
			siren_sfx.stream = SIREN_3
			if _fright_in_process == false:
				siren_sfx.play()
		15:
			siren_sfx.stream = SIREN_4
			if _fright_in_process == false:
				siren_sfx.play()

func execute_ending_sequence() -> void:
	get_tree().create_timer(2.0).timeout.connect(func() -> void:
		ghosts.visible = false
		tile_set.flash_walls()
	)
	tile_set.on_flashing_finished.connect(func() -> void:
		reset_the_level.emit()
	)
	pacman.set_physics_process(false)
	pacman.animated_sprite_2d.animation = "default"

func _execute_game_over() -> void:
	game_over_letters.visible = true

func die_pacman_die() -> void:
	ghosts.die_pacman_die()
