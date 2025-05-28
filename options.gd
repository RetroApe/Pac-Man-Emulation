class_name Options
extends Node2D

@onready var choice_yes_no: Node2D = %ChoiceYesNo

var choices: Array[Node]

func _ready() -> void:
	choices = choice_yes_no.get_children()
	
	for choice in choices as Array[Choice]:
		choice.option_toggled.connect(_on_option_toggled)

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
			else:
				choice.set_to_false()
