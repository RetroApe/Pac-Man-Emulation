extends Node

signal score_changed
signal level_changed
signal all_dots_eaten
signal no_lives_left

var turn_on_target_display := false
var turn_on_personal_dot_display := false
var turn_on_release_display := false

var turn_on_exit_timer_display := false
var turn_on_global_count_display := false
var turn_on_elroy_display := false
var turn_on_scatter_chase_display := false
var turn_on_speed_display := false
var turn_on_level_display := false
var turn_on_pinky_target_correction := false

var is_pacman_invincible := false

var current_level_counter := 1 : 
	set(new_level):
		current_level_counter = new_level
		level_changed.emit()
var current_level : Dictionary = {
	1: "level_1",
	2: "level_2",
	3: "level_3",
	4: "level_4",
	5: "level_5",
	6: "level_6",
	7: "level_7",
	8: "level_8",
	9: "level_9",
	10: "level_10",
	11: "level_11",
	12: "level_12",
	13: "level_13",
	14: "level_14",
	15: "level_15",
	16: "level_16",
	17: "level_17",
	18: "level_18",
	19: "level_19",
	20: "level_20",
	21: "level_21",
}

var player_ready_screen := true
var dots_eaten := 0 :
	set(new_dots):
		dots_eaten = new_dots
		if dots_eaten == 244:
			all_dots_eaten.emit()
var lives_remaining := 0 :
	set(new_lives):
		lives_remaining = new_lives
		if lives_remaining < 0:
			no_lives_left.emit()

var scatter_chase_timing : Dictionary[String, Array] = {
	"level_1": [7.0, 20.0, 7.0, 20.0, 5.0, 20.0, 5.0, -1.0],
	"level_2": [7.0, 20.0, 7.0, 20.0, 5.0, 1033.0 + 14.0/60.0, 1.0/60.0, -1.0],
	"level_3": [7.0, 20.0, 7.0, 20.0, 5.0, 1033.0 + 14.0/60.0, 1.0/60.0, -1.0],
	"level_4": [7.0, 20.0, 7.0, 20.0, 5.0, 1033.0 + 14.0/60.0, 1.0/60.0, -1.0],
	"level_5": [5.0, 20.0, 5.0, 20.0, 5.0, 1037.0 + 14.0/60.0, 1.0/60.0, -1.0],
}

var elroy_dot_count : Dictionary[String, int] = {
	"level_1": 20,
	"level_2": 30,
	"level_3": 40,
	"level_4": 40,
	"level_5": 40,
	"level_6": 50,
	"level_7": 50,
	"level_8": 50,
	"level_9": 60,
	"level_10": 60,
	"level_11": 60,
	"level_12": 80,
	"level_13": 80,
	"level_14": 80,
	"level_15": 100,
	"level_16": 100,
	"level_17": 100,
	"level_18": 100,
	"level_19": 120,
	"level_20": 120,
	"level_21": 120,
}

var scatter_chase_counter_start := 0
var fright_time : Dictionary[String, float] = {
	"level_1": 6.0,
	"level_2": 5.0,
	"level_3": 4.0,
	"level_4": 3.0,
	"level_5": 2.0,
	"level_6": 5.0,
	"level_7": 2.0,
	"level_8": 2.0,
	"level_9": 1.0,
	"level_10": 5.0,
	"level_11": 2.0,
	"level_12": 1.0,
	"level_13": 1.0,
	"level_14": 3.0,
	"level_15": 1.0,
	"level_16": 1.0,
	"level_17": 0.0,
	"level_18": 1.0,
	"level_19": 0.0,
	"level_20": 0.0,
	"level_21": 0.0,
}

var personal_dot_number : Dictionary[String, Array] = {
	"level_1": [0, 0, 30, 60],
	"level_2": [0, 0, 0, 50],
	"level_3": [0, 0, 0, 0]
}
var global_dot_counter_active := false
var global_dot_count := 0

var score := 0 : set = set_score
var highscore := 0

func set_score(new_score: int) -> void:
	score = new_score
	if score > highscore:
		highscore = score
	score_changed.emit()
