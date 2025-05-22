extends Node2D

@onready var dots: TileMapLayer = %Dots
@onready var energizers: TileMapLayer = %Energizers

func toggle_dots_visibility() -> void:
	dots.visible = false if dots.visible else true
	energizers.visible = false if energizers.visible else true
