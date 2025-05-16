extends Node2D

@onready var pac_man: PacMan = %PacMan
@onready var ghost: Ghost = %Ghost
@onready var frightened_timer: Timer = %FrightenedTimer

const GRID = preload("res://resources/Grid.tres")

var _scatter_chase_timing : Dictionary = {
	"level_1": [7.0, 20.0, 7.0, 20.0, 5.0, 20.0, 5.0, -1.0]
}
var _frightened_timing := 6.0

func _ready() -> void:
	pac_man.energizer_eaten.connect(_on_eaten_energizer)
	frightened_timer.timeout.connect(func() -> void:
		ghost.current_state = ghost.State.TARGETING
		ghost.speed = 1.0
	)

func _process(_delta: float) -> void:
	ghost.target_coordinates = pac_man.current_cell_coordinates
	if ghost.current_cell_coordinates == pac_man.current_cell_coordinates:
		if ghost.current_state == ghost.State.TARGETING:
			pac_man.death()
		if ghost.current_state == ghost.State.FRIGHTENED:
			ghost.death()
	
	if frightened_timer.time_left < 2.0 and !frightened_timer.is_stopped():
		ghost.animated_sprite_2d.animation = "frightened_flashing"

func _on_eaten_energizer() -> void:
	ghost.current_state = ghost.State.FRIGHTENED
	ghost.animated_sprite_2d.animation = "frightened"
	ghost.switch_direction()
	ghost.speed = 0.5
	frightened_timer.start(_frightened_timing)
