extends CanvasLayer

func _ready() -> void:
	GameState.crt_shader_changed.connect(func() -> void:
		visible = GameState.turn_on_crt
	)
