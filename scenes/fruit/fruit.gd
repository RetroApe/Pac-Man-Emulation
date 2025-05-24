class_name Fruit
extends Area2D

signal fruit_collected

@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D
@onready var timer: Timer = %Timer

var _fruit := {
	"cherry": {
		"points": 100,
		"sprite": 0
	},
	"strawberry": {
		"points": 200,
		"sprite": 1
	},
	"orange": {
		"points": 500,
		"sprite": 2
	},
	"apple": {
		"points": 700,
		"sprite": 3
	},
	"melon": {
		"points": 1000,
		"sprite": 4
	},
	"galaxian": {
		"points": 2000,
		"sprite": 5
	},
	"bell": {
		"points": 300,
		"sprite": 6
	},
	"key": {
		"points": 5000,
		"sprite": 7
	},
}
var level_to_fruit_conversion : Dictionary = {
	"level_1": "cherry",
	"level_2": "strawberry",
	"level_3": "orange",
	"level_4": "orange",
	"level_5": "apple",
	"level_6": "apple",
	"level_7": "melon",
	"level_8": "melon",
	"level_9": "galaxian",
	"level_10": "galaxian",
	"level_11": "bell",
	"level_12": "bell",
	"level_13": "key",
}
var _current_level := "level_1"
var _assigned_fruit : Dictionary = _fruit.cherry

func _ready() -> void:
	animated_sprite_2d.animation = "default"
	if GameState:
		if GameState.current_level_counter > 13:
			_current_level = "level_13"
		_assign_fruit(level_to_fruit_conversion[_current_level])
	body_entered.connect(func(body: Node2D) -> void:
		if typeof(body) == typeof(PacMan):
			GameState.score += _assigned_fruit.points
		animated_sprite_2d.animation = "points"
		animated_sprite_2d.frame = _assigned_fruit.sprite
		get_tree().create_timer(2.0).timeout.connect(queue_free)
	)
	timer.wait_time += randf()
	timer.start()
	timer.timeout.connect(queue_free)

func _assign_fruit (fruit : String = "apple") -> void:
	_assigned_fruit = _fruit[fruit]
	var frame : int = _assigned_fruit.sprite
	animated_sprite_2d.frame = frame
