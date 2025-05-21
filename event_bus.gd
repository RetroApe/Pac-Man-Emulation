extends Node

var current_level_counter := 1
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

var scatter_chase_timing : Dictionary = {
	"level_1": [7.0, 20.0, 7.0, 20.0, 5.0, 20.0, 5.0, -1.0],
	"level_2": [7.0, 20.0, 7.0, 20.0, 5.0, 1033.0 + 14.0/60.0, 1.0/60.0, -1.0],
	"level_3": [7.0, 20.0, 7.0, 20.0, 5.0, 1033.0 + 14.0/60.0, 1.0/60.0, -1.0],
	"level_4": [7.0, 20.0, 7.0, 20.0, 5.0, 1033.0 + 14.0/60.0, 1.0/60.0, -1.0],
	"level_5": [5.0, 20.0, 5.0, 20.0, 5.0, 1037.0 + 14.0/60.0, 1.0/60.0, -1.0],
}
