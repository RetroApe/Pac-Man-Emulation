extends Node2D

var timer : Timer
@export var blink_cycle_per_second := 2

func _ready() -> void:
	timer = Timer.new()
	
	add_child(timer)
	timer.start(1.0 / blink_cycle_per_second / 2.0)
	
	timer.timeout.connect(func() -> void:
		visible = not visible
	)
