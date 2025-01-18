extends CharacterBody2D

class_name Clonema

@export_category("Dependencies")
@export var spriteAnimator : TenmaSpriteAnimator;
@export var hitModule : TenmaHitModule;
@export var feetHitbox : CollisionShape2D;

@export_category("Stats")
@export var autoAttackSpeed : float = 1;
@export var health : int = 3;
@export var moveSpeed : float = 225;
@export var movementChance: float = 0.9 ;
@export var movementInterval  : float= 2;

var movementIntervalTimer : float = 0;
var doMovement : bool = false;
var movementTarget : Vector2;
var autoAttackTimer : float = 0;
var attackInProgress :bool = false;

var isActive : bool = true;
var enterProgress = 3; # 0 = entering, 1 = walking to player, 2= fully active;


signal onDeath;


func _ready() -> void:
	hitModule.getHit.connect(getHit);
	spriteAnimator.isClone = true;
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Player.instance == null):
		return;
	if (enterProgress == 0):
		doMovement = true
		hitModule.ignoreHits = true;
		feetHitbox.disabled = true;
		
		if (global_position.distance_squared_to(movementTarget) < 2500):
			enterProgress = 1;
			hitModule.ignoreHits = false;
		return;
	elif enterProgress == 1:
		feetHitbox.disabled = false;
		movementTarget = Player.instance.global_position;
		if (global_position.distance_squared_to(movementTarget) <  640000):
			enterProgress = 3
			hitModule.ignoreHits = false;
		return
	
	if (!attackInProgress && health > 0):
		spriteAnimator.setSprite("idle",0)
		autoAttackTimer -= delta;
		movementIntervalTimer -= delta;
		if (autoAttackTimer <= 0):
			autoAttack();
		if movementIntervalTimer <= 0:
			if randf() < movementChance:
				doMovement = true;
				generateRandomDestination()
			else:
				doMovement = false;
			movementIntervalTimer = movementInterval


func _physics_process(delta: float) -> void:
	if (doMovement && global_position.distance_squared_to(movementTarget) > 2500):
		spriteAnimator.isRunning = true
		global_position = global_position + global_position.direction_to(movementTarget) * moveSpeed * delta;
		if (global_position.distance_squared_to(movementTarget) < 2500):
			doMovement = false;
	else:
		spriteAnimator.isRunning = false;
	if (health <= 0):
		applyFriction(delta);
	move_and_slide()

func generateRandomDestination():
	var distance = global_position.distance_to(Player.instance.global_position);
	if (distance < 100):
		movementTarget = global_position + Player.instance.global_position.direction_to(global_position);
	elif (distance > 800):
		movementTarget = global_position + global_position.direction_to(Player.instance.global_position);
	else:
		if (randf() < 0.5): #forced movement towards player
			movementTarget = global_position + Vector2(1,0).rotated(global_position.angle_to_point(Player.instance.global_position) + randf_range(-PI/4,PI/4)) * 250;
		else:
			movementTarget = global_position + Vector2(1,0).rotated(randf_range(0,2*PI)) * 250;


func autoAttack():
	var r = randf();
	attackInProgress = true;
	autoAttackTimer = autoAttackSpeed;
	spriteAnimator.isShooting = true;
	if (doMovement):
		spriteAnimator.setSprite("run", 2)
	else:
		spriteAnimator.setSprite("throw",0);
	await get_tree().create_timer(0.1,false).timeout;
	if (doMovement):
		spriteAnimator.setSprite("run", 3)
	else:
		spriteAnimator.setSprite("throw",1);
	
	
	if r < 0.15:
		shootFanfire(Player.instance.global_position, 2, 0.3);
	else:
		SnowballSpawner.spawnSnowball(false, global_position, Player.instance.global_position, 1.75, 5);
	await get_tree().create_timer(0.3,false).timeout;
	
	spriteAnimator.isShooting = false;
	
	spriteAnimator.setSprite("idle",0);
	attackInProgress = false;
	
			

func shootFanfire(target: Vector2, amt : int, spread : float):
	var base : Vector2 = global_position.direction_to(target) ;
	SnowballSpawner.spawnSnowball(false, global_position, global_position+base, 1.75, 5)
	for i in range(1, amt):
		SnowballSpawner.spawnSnowball(false, global_position, global_position + base.rotated((i)*spread), 1.75, 5)
		SnowballSpawner.spawnSnowball(false, global_position, global_position + base.rotated((i)*-spread), 1.75, 5)
		
func getHit(s : Snowball):
	health -=1;
	enterProgress = 2;
	if (health ==0):
		takeKnockback(s.velocity.normalized() * 2)
		SoundManager.playSFX(SoundManager.snowKillSFX);
		die();
	if health >= 0:
		spriteAnimator.damagePulseClock = 0.5;
		SoundManager.playSFX(SoundManager.snowHitSFX);

func die():
	onDeath.emit();
	hitModule.ignoreHits = true;
	spriteAnimator.isDead = true;
	doMovement = false;
	await spriteAnimator.deathAnimFinished;
	
	queue_free();

func takeKnockback(value : Vector2):
	velocity = value * 500;
func applyFriction(delta : float):
	if (velocity.length() < 500*delta):
		velocity = Vector2.ZERO;
	velocity -= velocity * 10 * delta;
