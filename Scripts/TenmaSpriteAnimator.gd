extends Node2D;

class_name TenmaSpriteAnimator

@export var sprite: Sprite2D 
@export var outline: Sprite2D 
@export var outlineColor : Color :
	set(value):
		outlineColor = value;
		if(outline != null):
			outline.modulate = value;

@export_group("Sprites")
@export var idle : Texture2D;
@export var idle_outline: Texture2D;
@export var idle_frameCount : int = 1;
@export var dash : Texture2D;
@export var dash_outline : Texture2D;
@export var dash_frameCount : int = 1;
@export var hurt : Texture2D;
@export var hurt_outline : Texture2D;
@export var hurt_frameCount : int = 1;
@export var throw : Texture2D;
@export var throw_outline : Texture2D;
@export var throw_frameCount : int = 2;
@export var brick : Texture2D;
@export var brick_outline : Texture2D;
@export var brick_frameCount : int = 2;
@export var run : Texture2D;
@export var run_outline :Texture2D;
@export var run_frameCount : int = 4;



@export var isRunning : bool = false;
@export var isShooting : bool = false;
@export var isDashing : bool = false;
@export var isStaggered : bool = false;
@export var isDead : bool = false;
@export var isClone : bool = false;

var damagePulseClock: float = 0;
var animationClock : float;
var currentAnimation : String;

var inAnimation : bool = false;

signal deathAnimFinished();

func processAnimation():

	if (isDead):
		playDeathAnimation();
		return
	if (isRunning && !isShooting):
		playRunningAnimation();
		return;



func setSprite(spriteName : String, frame : int):
	sprite.texture = self[spriteName];
	outline.texture = self[spriteName+"_outline"]
	sprite.hframes = self[spriteName+"_frameCount"]
	outline.hframes = self[spriteName+"_frameCount"]
	sprite.frame = frame;
	outline.frame = frame;
	
	
	#print("set sprite to %s %d" % [spriteName, frame])

func _process(delta : float):
	animationClock += delta;
	damagePulseClock = clampf(damagePulseClock - delta, 0, damagePulseClock);
	processAnimation();
	doFlip();
	doDamagePulse()
	
func doDamagePulse():
	self.modulate.g = 1-(damagePulseClock);
	self.modulate.b = 1-(damagePulseClock);

func doFlip():
	if (Player.instance == null || isDead):
		return;
	var flip : bool = false if global_position.x - Player.instance.global_position.x < 0 else true;
	sprite.flip_h = flip;
	outline.flip_h = flip;
	

	
func playRunningAnimation():

	const runTimers = [0.3, 0.45];
	
	var frame :int = 0;
	for i in range(runTimers.size()):
		if animationClock > runTimers[i]:
			frame= (frame + 1) % runTimers.size();
	if (animationClock) >= 0.45:
		animationClock = 0;
	setSprite("run", frame);

func playDeathAnimation():
	if currentAnimation != "death":
		animationClock = 0;
		currentAnimation = "death";
	var deathTimers = [0.5,0.65,0.775,0.875,0.975] if isClone else [0.975];
	var frame :int = 0;
	for i in range(deathTimers.size()):
		if animationClock > deathTimers[i]:
			frame= (frame + 1) % deathTimers.size();
	setSprite("hurt",frame);
	if (animationClock >= 0.975):
		deathAnimFinished.emit();
