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


@export var isRunning : bool = false;
@export var isShooting : bool = false;
@export var isDashing : bool = false;
@export var isStaggered : bool = false;
@export var isDead : bool = false;


var animationClock : float;
var currentAnimation : String;

func processAnimation():

	if (isDead):
		return
	if (isStaggered):
		return
	if (isRunning):
		playRunningAnimation();
		return;
	playIdleAnimation();
	



func setSprite(spriteName : String, frame : int):
	sprite.texture = self[spriteName];
	outline.texture = self[spriteName+"_outline"]
	sprite.hframes = self[spriteName+"_frameCount"]
	outline.hframes = self[spriteName+"_frameCount"]
	sprite.frame = frame;
	outline.frame = frame;

func _process(delta : float):
	animationClock += delta;
	processAnimation();
	doFlip();

func doFlip():
	var flip : bool = false if get_local_mouse_position().x > 0 else true;
	sprite.flip_h = flip;
	outline.flip_h = flip;
	
####

func playIdleAnimation():		
	if currentAnimation != "idle" :
		animationClock = 0;
	const idleTimers = [1, 1.15, 1.90, 2.05];
	var frame : int = 0;
	for i in range(idleTimers.size()):
		if animationClock > idleTimers[i]:
			frame= (frame + 1) % idleTimers.size();
	if (animationClock) >= 2.05:
		animationClock =0;
		
	if (!isShooting):
		setSprite("idle", frame);
		currentAnimation = "idle";
	else:
		setSprite("shoot", 0);
		currentAnimation = "idleShoot";
	

	
func playRunningAnimation():

	const runTimers = [0.3, 0.45, 0.75, 0.9];
	
	var frame :int = 0;
	for i in range(runTimers.size()):
		if animationClock > runTimers[i]:
			frame= (frame + 1) % runTimers.size();
	if (animationClock) >= 0.9:
		animationClock =0;
		
	if (!isShooting):
		setSprite("run", frame);
	else:
		setSprite("runShoot", frame);
