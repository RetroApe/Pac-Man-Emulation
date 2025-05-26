extends HBoxContainer

var _fruit_sprites : Array[Node]
var _level : String
var _fruit : String

var _level_to_fruit_conversion : Dictionary = {
	"level_1": "cherry",
	"level_2": "strawberry",
	"level_3": "orange",
	"level_4": "orange",
	"level_5": "apple",
	"level_6": "apple",
	"level_7": "melon",
	"level_8": "melon",
	"level_9": "galaxian",
	"level_10": "galaxian",
	"level_11": "bell",
	"level_12": "bell",
	"level_13": "key",
}

func _ready() -> void:
	_fruit_sprites = get_children()
	clear()
	GameState.level_changed.connect(func() -> void:
		if GameState.current_level_counter <= 13:
			_level = GameState.current_level[GameState.current_level_counter]
		else:
			_level = "level_13"
		_fruit = _level_to_fruit_conversion[_level]
		for fruit in _fruit_sprites as Array[FruitSpriteUI]:
			if fruit.texture == null:
				fruit.assign_texture(_fruit)
				return
			
		for i in range(_fruit_sprites.size()):
			if i < _fruit_sprites.size() - 1:
				_fruit_sprites[i].texture = _fruit_sprites[i + 1].texture
			else:
				_fruit_sprites[i].assign_texture(_fruit)
	)

func set_up() -> void:
	var level_count = GameState.current_level_counter if GameState.current_level_counter <= 13 else 13
	_level = GameState.current_level[level_count]
	_fruit = _level_to_fruit_conversion[_level]
	if _level == "level_1":
		_first_level()
	else:
		clear()
		var count := GameState.current_level_counter - 6
		if count < 0: count = 1
		for i in range(min(_fruit_sprites.size(), GameState.current_level_counter)):
			var j = count + i
			if j < 13:
				_fruit_sprites[i].assign_texture(_level_to_fruit_conversion[GameState.current_level[j]])
			else:
				_fruit_sprites[i].assign_texture("key")
		

func _first_level() -> void:
	clear()
	_fruit_sprites[0].assign_texture("cherry")
	

func clear() -> void:
	for fruit in _fruit_sprites:
		fruit.remove_texture()
