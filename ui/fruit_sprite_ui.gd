class_name FruitSpriteUI
extends Sprite2D

var atlas_texture := AtlasTexture.new()
const GENERAL_SPRITES = preload("res://assets/sprites/general_sprites.png")

var fruit_atlas_region := {
	"cherry": Rect2(34.0, 50.0, 12.0, 13.0),
	"strawberry": Rect2(50.0, 50.0, 12.0, 13.0),
	"orange": Rect2(66.0, 50.0, 12.0, 13.0),
	"apple": Rect2(82.0, 50.0, 12.0, 13.0),
	"melon": Rect2(99.0, 50.0, 11.0, 13.0),
	"galaxian": Rect2(114.0, 50.0, 11.0, 13.0),
	"bell": Rect2(130.0, 50.0, 12.0, 13.0),
	"key": Rect2(148.0, 50.0, 7.0, 13.0),
}

func _ready() -> void:
	atlas_texture.atlas = GENERAL_SPRITES
	

func assign_texture(fruit_name : String) -> void:
	atlas_texture = atlas_texture.duplicate()
	atlas_texture.region = fruit_atlas_region[fruit_name]
	texture = atlas_texture

func remove_texture() -> void:
	texture = null
