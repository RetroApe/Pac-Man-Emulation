class_name MyTiles
extends Node2D

signal on_flashing_finished

@onready var dots: TileMapLayer = %Dots
@onready var energizers: TileMapLayer = %Energizers
@onready var walls: Walls = %Walls

var _count := 1

func toggle_dots_visibility() -> void:
	dots.visible = false if dots.visible else true
	energizers.visible = false if energizers.visible else true

func flash_walls() -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.start(2.0 / 10.0)
	_count = 0
	walls.toggle_walls()
	timer.timeout.connect(func() -> void:
		_count += 1
		if _count == 8:
			#timer.set_deferred("paused", true)
			timer.paused = true
			walls.visible = false
			on_flashing_finished.emit()
		walls.toggle_walls()
	)
