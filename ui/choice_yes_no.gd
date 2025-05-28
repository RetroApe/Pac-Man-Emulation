class_name Choice
extends Area2D

signal option_toggled

@onready var no: Sprite2D = %No
@onready var yes: Sprite2D = %Yes

@export var start_on_yes := false
@export var option_variable: String

func _ready() -> void:
	if start_on_yes:
		set_to_true()
	else:
		set_to_false()
		

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	var event_is_mouse_click: bool = (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed()
	)
	if event_is_mouse_click:
		toggle_display()
		assert(option_variable, "Option variable is missing.")
		if option_variable != null:
			option_toggled.emit(yes.visible, option_variable)

func toggle_display() -> void:
	yes.visible = not yes.visible
	no.visible = not no.visible

func set_to_true() -> void:
	yes.visible = true
	no.visible = false

func set_to_false() -> void:
	yes.visible = false
	no.visible = true

func get_state() -> bool:
	return yes.visible
