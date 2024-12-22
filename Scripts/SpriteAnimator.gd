extends Node2D;

class_name SpriteAnimator

@export var sprite: Sprite2D 
@export var outline: Sprite2D 
@export var outlineColor : Color :
	set(value):
		outlineColor = value;
		outline.modulate = value;

@export_group("Sprites")
@export_subgroup("Universal")
@export var idle : Texture2D;
@export var idle_outline: Texture2D;
@export var idle_frameCount : int = 4;
@export var run : Texture2D;
@export var run_outline : Texture2D;
@export var run_frameCount : int = 4;
@export var hurt : Texture2D;
@export var hurt_outline : Texture2D;
@export var hurt_frameCount : int = 1;
@export var death : Texture2D;
@export var death_outline : Texture2D;
@export var death_frameCount : int = 1;

@export_subgroup("Pippa Only")
@export var shoot : Texture2D;
@export var shoot_outline : Texture2D;
@export var shoot_frameCount : int = 1;
@export var runShoot : Texture2D;
@export var runShoot_outline : Texture2D;
@export var runShoot_frameCount : int = 4;

@export_subgroup("Tenma Only")
@export var throwPoise : Texture2D;
@export var throwPoise_outline : Texture2D;
@export var throwPoise_frameCount : int = 1;
@export var afterThrow : Texture2D;
@export var afterThrow_outline : Texture2D;
@export var afterThrow_frameCount : int = 1;


func setSprite(spriteName : String, frame : int):
	sprite.texture = self[spriteName];
	outline.texture = self[spriteName+"_outline"]
	sprite.hframes = self[spriteName+"_frameCount"]
	outline.hframes = self[spriteName+"_frameCount"]
	sprite.frame = frame;
	outline.frame = frame;

func _process(delta : float):
	var flip : bool = false if get_local_mouse_position().x > 0 else true;
	sprite.flip_h = flip;
	outline.flip_h = flip;
	
