extends CharacterBody2D

class_name Player;

static var instance : Player;

@export_group("Dependencies")
@export var spriteAnimator : SpriteAnimator;
@export var movementModule : MovementModule;
@export var shootModule : ShootModule;
@export var hitModule : PippaHitModule;
@export var feetHitBox :CollisionShape2D;
@export var dashTrail : DashTrail;


@export_group("Stats")
@export var hp = 5;

var isDead : bool = false;
var hitByBrickCounter : int = 0;

var timeToRegen: float = 7;
var regenTimer: float;
var doRegen: bool = false;

signal onDeath;

func _ready() -> void:
	instance = self;
	hitModule.onHit.connect(onHit);
	regenTimer = timeToRegen;
	movementModule.dashTrail = dashTrail;
	dashTrail.parent = self;
	dashTrail.spriteAnimator = spriteAnimator
	

func _physics_process(delta: float) -> void:
	move_and_slide();

func onHit(area : Area2D):
	hp = clamp(hp-1, 0, 5);
	if area.type=="Brick":
		hitByBrickCounter +=1;
	regenTimer = timeToRegen;
	if hp == 0:
		if (area.type=="Brick"):
			hitByBrickCounter += 9;
		die()
		
func die():
	isDead = true;
	spriteAnimator.isDead = true;
	hitModule.ignoreHits = true;
	SoundManager.playSFX(SoundManager.pippaDeathSFX)
	onDeath.emit();


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(staggerTimer)
	movementModule.allowMovement = !isDead && hitModule.staggerTimer <= 0;
	shootModule.allowShoot = !isDead && hitModule.staggerTimer <=0;	
	spriteAnimator.isImmune = !isDead && hitModule.invulnerabilityTimer > 0;
	
	regenTimer = clampf(regenTimer-delta, 0, timeToRegen);
	if (doRegen && regenTimer == 0):
		hp = clamp(hp + 1, 0, 5);
		regenTimer = timeToRegen
	

func state_idle():
	movementModule.allowMovement = true;
	shootModule.allowShoot = true;
