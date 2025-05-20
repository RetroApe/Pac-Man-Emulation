extends Node

var current_level_counter := 1
var current_level : Dictionary = {
	1: "level_1",
	2: "level_2",
	3: "level_3",
	4: "level_4",
	5: "level_5",
}

var scatter_chase_timing_counter := 0
var scatter_chase_timing : Dictionary = {
	#"level_1": [7.0, 20.0, 7.0, 20.0, 5.0, 20.0, 5.0, -1.0]
	"level_1": [1.0, 2.0, 3.0, 4.0, 5.0, 20.0, 5.0, -1.0]
}
