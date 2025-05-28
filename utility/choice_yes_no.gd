extends Area2D

@onready var no: Sprite2D = %No
@onready var yes: Sprite2D = %Yes

@export var start_on_yes := false

func _ready() -> void:
	if start_on_yes:
		yes.visible = true
		no.visible = false
	else:
		yes.visible = false
		no.visible = true



func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	var event_is_mouse_click: bool = (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed()
	)
	if event_is_mouse_click:
		yes.visible = not yes.visible
		no.visible = not no.visible
