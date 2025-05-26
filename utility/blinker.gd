class_name Blinker
extends Node2D

var timer : Timer
@export var blink_cycle_per_second := 2

func _ready() -> void:
	timer = Timer.new()
	
	add_child(timer)
	
	timer.timeout.connect(func() -> void:
		visible = not visible
	)

func please_proceed_to_blink() -> void:
	timer.start(1.0 / blink_cycle_per_second / 2.0)
	
func stop_with_all_this_blinking_pretty_please() -> void:
	timer.stop()
	visible = true
