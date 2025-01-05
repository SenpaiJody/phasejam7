extends Area2D

class_name Theo

@export var sprite : Sprite2D;
@export var outline : Sprite2D;

@export var isAlly : bool = true;
@export var speed : int = 350;

enum PROGRESS {FLYING, THROWING, FALLING, LANDING, RETURNING}
@export var progress : PROGRESS = PROGRESS.FLYING;

@export var velocity : Vector2;
@export var type = "Theo";
@export var target : Node2D;
@export var returnTarget: Node2D;
var progressTimer : float;

var animationClock : float;

signal onReturned;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func straight(origin : Vector2, targetPosition : Vector2, speed : float, timeUntilFired : float, targetAngleOffset : float = 0):
	global_position = origin;
	progressTimer = timeUntilFired;
	velocity = origin.direction_to(targetPosition).rotated(targetAngleOffset) * speed;
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progressTimer -= delta;
	if (progressTimer <= 0):
		if (progress == PROGRESS.FLYING):
			shoot();
			progress = PROGRESS.THROWING;
			progressTimer = 0.1;
			animationClock = 0;
		elif (progress == PROGRESS.THROWING):
			progressTimer = 0.5;
			animationClock = 0;
			progress = PROGRESS.FALLING;
		elif (progress == PROGRESS.FALLING):
			progress = PROGRESS.LANDING;
			animationClock = 0;
			progressTimer = 0.5;
		elif progress == PROGRESS.LANDING:
			progress = PROGRESS.RETURNING;
			animationClock = 0;
			progressTimer = 0
	doFlip();
	doAnimation(delta);
func _physics_process(delta: float) -> void:
	
	if (progress == PROGRESS.FLYING):
		global_position += velocity * speed * delta;
	elif (progress == PROGRESS.FALLING):
		global_position += (velocity * speed * 0.3 * delta) + Vector2(0, 100) * delta;
	elif (progress == PROGRESS.RETURNING):
		global_position += speed * global_position.direction_to(returnTarget.global_position) * delta ;
		if (global_position.distance_to(returnTarget.global_position) < 25):
			onReturned.emit();
			queue_free();
			
func shoot():
	SnowballSpawner.spawnSnowball(false, global_position, target.global_position, 2, 3);
	
	
func setFrame(frame : int):
	sprite.frame = frame;
	outline.frame = frame;

func doAnimation(delta : float):
	
	if progress == PROGRESS.FLYING:
		if (animationClock >= 0.1):
			setFrame(1 if sprite.frame == 0 else 0)
			animationClock = 0;
	elif progress == PROGRESS.THROWING:
		setFrame(2);
	elif progress == PROGRESS.FALLING:
		setFrame(3);
	elif progress == PROGRESS.LANDING:
		setFrame(4);
	elif progress == PROGRESS.RETURNING:
		if (animationClock >= 0.1):
			setFrame(6 if sprite.frame == 5 else 5)
			animationClock = 0;
		
	
	
	animationClock += delta;
	
	
func doFlip():
	if (progress == PROGRESS.RETURNING):
		sprite.flip_h = global_position.x - returnTarget.global_position.x > 10
		outline.flip_h = global_position.x - returnTarget.global_position.x > 10
	else:
		sprite.flip_h = global_position.x - target.global_position.x > 0
		outline.flip_h = global_position.x - target.global_position.x > 0
