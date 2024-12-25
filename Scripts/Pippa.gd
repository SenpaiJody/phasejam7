extends CharacterBody2D

@export_group("Dependencies")
@export var spriteAnimator : SpriteAnimator;
@export var movementModule : MovementModule;
@export var shootModule : ShootModule;

@export_category("Timers")
@export var staggerTimer : float;

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
	staggerTimer -= delta;

func state_idle():
	movementModule.allowMovement = true;
	shootModule.allowShoot = true;



func state_staggered():
	movementModule.allowMovement = false;
	movementModule.allowShoot = true;
	##Will this have issues if the parent is deleted before this resolves?
	get_tree().create_timer(0.5).timeout.connect(func():state = states.IDLE);
	
func state_dashing():
	movementModule.allowMovement = false;
	movementModule.allowShoot = true;
	##Will this have issues if the parent is deleted before this resolves?
	get_tree().create_timer(0.5).timeout.connect(func():state = states.IDLE);
	
func state_dead():
	movementModule.allowMovement = false;
	movementModule.allowShoot = true;
