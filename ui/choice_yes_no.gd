class_name Choice
extends Area2D

signal option_toggled

@onready var no: Sprite2D = %No
@onready var yes: Sprite2D = %Yes

@export var tooltip: PackedScene
@export var start_on_yes := false
@export var option_variable: String

var _tooltip_node: HBoxContainer

func _ready() -> void:
	if start_on_yes:
		set_to_true()
	else:
		set_to_false()
	
	mouse_entered.connect(_set_tooltip.bind(true))
	mouse_exited.connect(_set_tooltip.bind(false))

func _input_event(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	var event_is_mouse_click: bool = (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.is_pressed()
	)
	if event_is_mouse_click:
		viewport.set_input_as_handled()
		toggle_display()
		assert(option_variable, "Option variable is missing.")
		if option_variable != null:
			option_toggled.emit(yes.visible, option_variable)

func _set_tooltip(value := false) -> void:
	if tooltip == null:
		return
	if value:
		_tooltip_node = tooltip.instantiate()
		add_child(_tooltip_node)
	else:
		_tooltip_node.queue_free()

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
