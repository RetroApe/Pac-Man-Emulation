class_name Options
extends Node2D

@onready var choice_yes_no: Control = %ChoiceYesNo
@onready var options_window_puller: Area2D = %OptionsWindowPuller
@onready var window: Node2D = %OptionsWindow
@onready var area_bg: Area2D = %AreaBG

var choices: Array[Node]
var options_opened := false
var tween: Tween
var tween_scale: Tween
var window_closed_position: Vector2

func _ready() -> void:
	choices = choice_yes_no.get_children()
	for choice in choices as Array[Choice]:
		choice.option_toggled.connect(_on_option_toggled)
	
	area_bg.input_pickable = false
	window_closed_position = window.position
	options_window_puller.input_event.connect(func(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
		var is_mouse_click: bool = (
			event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
		)
		
		if is_mouse_click and options_opened == false:
			viewport.set_input_as_handled()
			area_bg.input_pickable = true
			if tween != null:
				if tween.is_running():
					tween.kill()
			tween = create_tween()
			tween.set_ease(Tween.EASE_OUT)
			tween.set_trans(Tween.TRANS_CUBIC)
			tween.tween_property(window, "position", Vector2.ZERO, 1.0)
			options_opened = true
	)
	options_window_puller.mouse_entered.connect(func() -> void:
		if tween_scale != null:
			if tween_scale.is_running():
				tween_scale.kill()
		tween_scale = create_tween()
		tween_scale.tween_property(options_window_puller, "scale", Vector2(1.1, 1.1), 0.15)
	)
	options_window_puller.mouse_exited.connect(func() -> void:
		if tween_scale != null:
			if tween_scale.is_running():
				tween_scale.kill()
		tween_scale = create_tween()
		tween_scale.tween_property(options_window_puller, "scale", Vector2.ONE, 0.15)
	)
	
	area_bg.input_event.connect(func(viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
		var is_mouse_click: bool = (
			event is InputEventMouseButton
			and event.is_pressed()
			and event.button_index == MOUSE_BUTTON_LEFT
		)
		
		if is_mouse_click:
			viewport.set_input_as_handled()
			_set_closed_position()
	)

func _on_option_toggled(is_true: bool, option_variable: String) -> void:
			if is_true == false and option_variable != "turn_on_all_displays":
				find_child("All").set_to_false()
			match option_variable:
				"turn_on_all_displays":
					_turn_all(is_true)
				"turn_on_target_display":
					GameState.turn_on_target_display = is_true
				"turn_on_personal_dot_display":
					GameState.turn_on_personal_dot_display = is_true
				"turn_on_release_display":
					GameState.turn_on_release_display = is_true
				"turn_on_exit_timer_display":
					GameState.turn_on_exit_timer_display = is_true
				"turn_on_global_count_display":
					GameState.turn_on_global_count_display = is_true
				"turn_on_elroy_display":
					GameState.turn_on_elroy_display = is_true
				"turn_on_scatter_chase_display":
					GameState.turn_on_scatter_chase_display = is_true
				"turn_on_speed_display":
					GameState.turn_on_speed_display = is_true
				"turn_on_level_display":
					GameState.turn_on_level_display = is_true
				"turn_on_pinky_target_correction":
					GameState.turn_on_pinky_target_correction = is_true
				"crt":
					GameState.turn_on_crt = is_true
			
			if is_true == true and option_variable != "turn_on_all_displays":
				var all_options_set_to_true := true
				for choice in choices as Array[Choice]:
					if choice.get_state() == false and choice.get_index() != 0:
						all_options_set_to_true = false
				if all_options_set_to_true == true:
					choices[0].toggle_display()

func _turn_all(is_true: bool) -> void:
	for choice in choices as Array[Choice]:
		if choice.option_variable != "turn_on_all_displays":
			if is_true:
				choice.set_to_true()
				GameState.set_all_options_to(true)
			else:
				choice.set_to_false()
				GameState.set_all_options_to(false)

func _input(_event: InputEvent) -> void:
	if (
			(
					Input.is_action_just_pressed("level_start") 
					or Input.is_action_just_pressed("level_exit")
			)
			and options_opened == true
	):
		get_viewport().set_input_as_handled()
		_set_closed_position()

func _set_closed_position() -> void:
	area_bg.input_pickable = false
	if tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(window, "position", window_closed_position, 1.0)
	options_opened = false
