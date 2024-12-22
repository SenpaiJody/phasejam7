extends CharacterBody2D


@export var spriteAnimator : SpriteAnimator;
@export var movementModule : MovementModule;
@export var shootModule : ShootModule;

signal next_frame(float);


enum states {IDLE, SHOOT, STAGGERED, DASHING, DEAD}
var state : states :
	set(value):
		if (state != value):
			state = value;
			match value:
				states.IDLE:
					state_idle();
				states.STAGGERED:
					state_staggered();
				states.DASHING:
					state_dashing();
				states.DEAD:
					state_dead();
var stateChanged : bool = false;



func _ready() -> void:
	state = states.IDLE;
	state_idle();

func _physics_process(delta: float) -> void:
	move_and_slide();




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	next_frame.emit(delta);
	pass

func state_idle():
	var animTimer : float = 0;
	const idleTimers = [1, 0.15, 0.75, 0.15];
	const runTimers = [0.3, 0.15, 0.3, 0.15];
	var frame = 0;
	
	var shootAnimTime = -1;
	
	
	
	while state == states.IDLE:
		var delta : float = await next_frame;
		movementModule.allowMovement = true;
		animTimer += delta;
		
		if (movementModule.isMoving != movementModule.delta_isMoving):
			animTimer = 0;
			frame = 0;
			spriteAnimator.setSprite("run" if movementModule.isMoving else "idle", frame);
			
		if (!movementModule.isMoving && animTimer >= idleTimers[frame]) || (movementModule.isMoving && animTimer >= runTimers[frame]):
			animTimer = 0;
			frame+=1;
			if (frame > 3):
				frame = 0;
			
			
			spriteAnimator.setSprite("run" if movementModule.isMoving else "idle", frame);
		
		if (shootModule.justShot):
			shootAnimTime = 0.25;
		
		if (shootAnimTime > 0):
			if (movementModule.isMoving):
				spriteAnimator.setSprite("runShoot",frame);
			else:
				spriteAnimator.setSprite("shoot", 0);
			shootAnimTime = shootAnimTime - delta;
			if (shootAnimTime <= 0):
				if (movementModule.isMoving):
					spriteAnimator.setSprite("run", frame);
				else:
					spriteAnimator.setSprite("idle", 0);
					frame = 0;
				
				shootAnimTime = -1;
		
		
		
	movementModule.allowMovement = false;



func state_staggered():
	pass
	
func state_dashing():
	pass
	
func state_dead():
	pass
