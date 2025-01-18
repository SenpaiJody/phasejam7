extends CharacterBody2D

class_name Tenma

@export var aggression: float = 3;
@export var spriteAnimator : TenmaSpriteAnimator;
@export var hitModule : TenmaHitModule;
@export var feetHitbox : CollisionShape2D;

@export var hp : int = 50
@export var maxHP : int = 50

var isDead : bool = false;
signal onDeath;

var nextAttackTimer : float = 0;

var initializationTimer = 1;

var dashSpeed : float = 900;
var dashDirection : Vector2;
var distanceToDash : float;
var dashSpeedFactor;

signal dashStart;
signal dashQuarterCompleted;
signal dashHalfCompleted;
signal dashThreeQuarterCompleted;
signal dashCompleted;

signal attackCompleted;
var attackInProgress :bool = false;
var recentlyHitWall : bool = false;
@export var autoAttackSpeed : float = 1;
var autoAttackTimer : float = 0;

var dashDistanceRemaining : float;
var brickReady : bool = false;
var theoReady : bool = true;

func _ready() -> void:
	
	attackCompleted.connect(
		func():
			spriteAnimator.setSprite("idle",0);
			attackInProgress = false;
			nextAttackTimer = aggression
			);
	nextAttackTimer = aggression
	
	hitModule.getHit.connect(getHit);
	
	#spriteAnimator.setSprite("idle",0);
func applyFriction(delta : float):
	if (velocity.length() < 500*delta):
		velocity = Vector2.ZERO;
	velocity -= velocity * 10 * delta;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (Player.instance == null):
		return;
	initializationTimer = clampf(initializationTimer-delta, 0, 2);
	if (initializationTimer > 0):
		return;
		
	#print(nextAttackTimer)
	nextAttackTimer -= delta;
	if (!attackInProgress):
		
		autoAttackTimer -= delta;
		if nextAttackTimer <= 0:
			randomizeAttack();
		elif (autoAttackTimer <= 0):
			autoAttack();
			

func _physics_process(delta: float) -> void:
	physics_process_dash(delta);
	applyFriction(delta);
	move_and_slide()

func randomizeAttack():
	if (isDead || Player.instance.isDead):
		return;
	nextAttackTimer = aggression;
	if (recentlyHitWall):
		attackInProgress = true;
		longDashToCenter();
		return;
	
	var r = randf();
	
	#if r < 0.3:
		#attackInProgress = false;
		#return;
	attackInProgress = true;
	autoAttackTimer = autoAttackSpeed;
		#print("wait")	
	#print(r);
	if r < 0.8: #dashAttack
		if randf() < 0.8:
			shortDashAttack()
		else:
			longDashAttack()
	elif r < 1:
		smartBrickAttack(1.5);
	



func dash(destination: Vector2):
	if (isDead || Player.instance.isDead):
		return;
	spriteAnimator.setSprite("dash",0)
	var query = PhysicsRayQueryParameters2D.create(global_position, destination)
	query.exclude = [self];
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	if (result.size() != 0):
		recentlyHitWall = true;
		destination = result.position;
	else:
		recentlyHitWall = false;
		
	dashSpeedFactor = 1
	distanceToDash = global_position.distance_to(destination);
	dashDirection = global_position.direction_to(destination);
	dashDistanceRemaining = distanceToDash;

	dashStart.emit();
	

func physics_process_dash(delta : float):
	if (dashDistanceRemaining > 0):
		#print("%f | %f" % [dashSpeed * delta, dashDistanceRemaining]);
		var d = min(dashSpeed *dashSpeedFactor * delta, dashDistanceRemaining);
		global_position += dashDirection * d;
		dashDistanceRemaining = clampf(dashDistanceRemaining - d, 0, distanceToDash);
		if dashDistanceRemaining/distanceToDash < 0.15:
			dashSpeedFactor = 0.6;
			dashThreeQuarterCompleted.emit();
		elif dashDistanceRemaining/distanceToDash < 0.55:
			dashSpeedFactor = 0.8;
			dashHalfCompleted.emit();
		elif dashDistanceRemaining/distanceToDash < 0.95:
			dashSpeedFactor = 1
			dashQuarterCompleted.emit();
		if dashDistanceRemaining/distanceToDash <= 0:
			dashCompleted.emit();
	
func autoAttack():
	if (isDead || Player.instance.isDead):
		return;
	var r = randf();
	attackInProgress = true;
	autoAttackTimer = autoAttackSpeed;
	spriteAnimator.setSprite("throw",0);
	await get_tree().create_timer(0.1,false).timeout;
	spriteAnimator.setSprite("throw",1);
	
	if r < 0.15 && theoReady:
		tossTheo();
	elif r < 0.4:
		shootFanfire(Player.instance.global_position, 1.75, 0.3);
	else:
		SnowballSpawner.spawnSnowball(false, global_position, Player.instance.global_position, 1.75, 5);
	await get_tree().create_timer(0.3,false).timeout;
	spriteAnimator.setSprite("idle",0);
	attackInProgress = false;
	

func shortDashAttack():
	#short leap ~300 units, shooting 3 evenly spaced snowballs at the 1/4, 2/4, and 3/4 points
	var angle = randf_range(0, PI/6);
	var rotation = global_position.angle_to_point(Player.instance.global_position);
	if Player.instance.global_position.distance_to(global_position) < 600:
		angle += (PI/2 if randf() > 0.5 else -PI/2)		
		
	var f = func(): 
		spriteAnimator.setSprite("dash",1);
		await get_tree().create_timer(0.1,false).timeout;
		spriteAnimator.setSprite("dash",2);
		SnowballSpawner.spawnSnowball(false, global_position, Player.instance.global_position, 2, 5);
		await get_tree().create_timer(0.1,false).timeout;
		spriteAnimator.setSprite("idle",0);
	if randf() < 0.85:
		dashQuarterCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
		dashHalfCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
		dashThreeQuarterCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
	else:
		dashHalfCompleted.connect(
			func(): 
				shootFanfire(Player.instance.global_position, 1.75, 0.3), ConnectFlags.CONNECT_ONE_SHOT);
		
	dash(global_position + Vector2(300,0).rotated(rotation+angle));
	dashCompleted.connect(
		func():
			#print("Attack Completed");
			#spriteAnimator.setSprite("idle",0);
			attackCompleted.emit();
			, ConnectFlags.CONNECT_ONE_SHOT);
	

func longDashAttack():
	#long leap ~600 units; only dashes sideways same as shortDashAttack();
	var angle = randf_range(0, PI/6);
	var rotation = global_position.angle_to_point(Player.instance.global_position);
	angle += (PI/2 if randf() > 0.5 else -PI/2)		
		
	var f = func(): 
		spriteAnimator.setSprite("dash",1);
		await get_tree().create_timer(0.1,false).timeout;
		spriteAnimator.setSprite("dash",2);
		SnowballSpawner.spawnSnowball(false, global_position, Player.instance.global_position, 2, 5);
		await get_tree().create_timer(0.1,false).timeout;
		spriteAnimator.setSprite("idle",0);
	dashQuarterCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
	dashHalfCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
	dashThreeQuarterCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
		
	dash(global_position + Vector2(600,0).rotated(rotation+angle));
	dashCompleted.connect(
		func():
			
			#print("Attack Completed");
			attackCompleted.emit();
			, ConnectFlags.CONNECT_ONE_SHOT);

func longDashToCenter():
	var f = func(): SnowballSpawner.spawnSnowball(false, global_position, Player.instance.global_position, 1.75, 5);
	dashQuarterCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
	dashHalfCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
	dashThreeQuarterCompleted.connect(f, ConnectFlags.CONNECT_ONE_SHOT);
		
	dash(Vector2(randi_range(-120,120),randi_range(-120,120)));
	dashCompleted.connect(
		func():
			attackCompleted.emit();
			, ConnectFlags.CONNECT_ONE_SHOT);
			

func shootFanfire(target: Vector2, amt : int, spread : float):
	var base : Vector2 = global_position.direction_to(target) ;
	SnowballSpawner.spawnSnowball(false, global_position, global_position+base, 1.75, 5)
	for i in range(1, amt):
		SnowballSpawner.spawnSnowball(false, global_position, global_position + base.rotated((i)*spread), 1.75, 5)
		SnowballSpawner.spawnSnowball(false, global_position, global_position + base.rotated((i)*-spread), 1.75, 5)
		


func _tossSmartBrick(direction: Vector2, destination : Vector2):
	var distance = global_position.distance_to(destination);
	var speed = 3

	if distance < 400:
		destination -= direction * distance * 2.5/100;
		speed = 2.8
	elif (distance > 400 && distance < 800):
		destination += direction * distance * 2.5/100;
		speed = 3.5
	elif distance >= 800:
		speed = 4
		destination += direction * distance * 3.5/100	
	spriteAnimator.setSprite("brick",1);
	if (brickReady == true):
		SnowballSpawner.spawnBrick(global_position, destination, speed, 3);
		brickReady = false;

func smartBrickAttack(time : float):
	brickReady = true;
	spriteAnimator.setSprite("brick",0);
	await get_tree().create_timer(0.15,false).timeout; #leniencyTimer
	var timer :SceneTreeTimer = get_tree().create_timer(time - 0.15,false)
	var tossed : bool = false;
	
	var coroutine = func(direction: Vector2, destination : Vector2):
		if (!isDead):
			_tossSmartBrick(direction, destination);
			timer.timeout.emit();
		brickReady = false;
			
	Player.instance.movementModule.onDash.connect(coroutine, ConnectFlags.CONNECT_ONE_SHOT);
	await timer.timeout;
	if (brickReady == true && !isDead):
		_tossSmartBrick(global_position.direction_to(Player.instance.global_position), Player.instance.global_position);
		brickReady = false;
		spriteAnimator.setSprite("brick",1);
	await get_tree().create_timer(0.3,false).timeout;
	spriteAnimator.setSprite("idle",0);
	if (Player.instance.movementModule.onDash.is_connected(coroutine)):
		Player.instance.movementModule.onDash.disconnect(coroutine);
	#print("emnding SmartBrickToss")
	attackCompleted.emit();

func tossTheo():
	theoReady = false;
	var angle = (1 if randf() > 0.5 else -1) * (randf_range(PI/6, PI/4));
	var sg : Signal = SnowballSpawner.spawnTheo(global_position, self, Player.instance, Player.instance.global_position, 1, randf_range(0.75, 1.5), angle);
	sg.connect(func():theoReady = true, ConnectFlags.CONNECT_ONE_SHOT);

func takeKnockback(value : Vector2):
	velocity = value * 500;

func getHit(s : Snowball):
	hp -=1;
	if (hp ==0):
		takeKnockback(s.velocity.normalized() * 3)
		SoundManager.playSFX(SoundManager.snowKillSFX);
		die();
	if hp >= 0:
		spriteAnimator.damagePulseClock = 0.5;
		SoundManager.playSFX(SoundManager.snowHitSFX);
	
	
func die():
	onDeath.emit();
	hitModule.ignoreHits = true;
	spriteAnimator.isDead = true;
	isDead = true;
