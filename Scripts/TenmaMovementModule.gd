extends Node2D;
class_name TenmaMovementModule;

@export_category("Dependencies")
@export var body : CharacterBody2D;
#@export var animator : SpriteAnimator;
#@export var dashTrail : DashTrail;
@onready var playableRect = $"../../PlayableArea"
var playableArea : Rect2;

@export_category("Variables")
@export var speed : float = 300.0;
@export var acceleration : float = 2500.0;
@export var friction : float = 10.0;

@export var player : CharacterBody2D;

@export var dashStrength = 1300;

var targetPosition;

var movementDirection;

var allowMovement : bool = false;
var isMoving : bool = false;

enum movementStates {SPACING, GET_OFF_ME, PURSUIT, TARGETTED_DASH,}

@export_category("Spacing")
@export var doSpacing : bool = false;
@export var timeBetweenSpacing: float = 3;
@export var timeBetweenSpacingVariation : float = 2;
var spacingTimer : float;

@export_category("GetOffMe/Pursuit")
@export var getOffMeDistance : float = 300;
@export var pursuitDistance : float = 400;

var movementStateTimer = 0.2;
var circlingTimer = 1;
var circlingDirection = 1;


func _ready() -> void:
	#var r : ReferenceRect = get_tree().root.find_child("PlayableArea")
	playableArea = Rect2(playableRect.global_position, playableRect.size)
	
	state_spacing();

func _process(delta: float) -> void:
	moveTowardsTarget(delta);
	applyFriction(delta);
	isMoving = movementDirection != Vector2.ZERO;
	spacingTimer -= delta;
	movementStateTimer-=delta;
	
	#animator.isRunning = isMoving;
	
	determineMovementState(delta);
	#print(targetPosition)
	
func determineMovementState(delta : float):
	var dist_to_player = global_position.distance_to(player.global_position);
	
	
	#specific attacks
	
	
	
	#default movement types
	if (movementStateTimer <= 0):
		movementStateTimer = 0.2;
		state_default(delta);
	#return;
	#if (dist_to_player < getOffMeDistance):
		#state_get_off_me();
	#elif (dist_to_player > pursuitDistance):
		#state_pursuit();
	#else:
		#state_circle();

func applyFriction(delta : float):
	if (body.velocity.length() < 500*delta):
		body.velocity = Vector2.ZERO;
	body.velocity -= body.velocity * friction * delta;


func moveTowardsTarget(delta:float):
	if (targetPosition != null):
		body.velocity += global_position.direction_to(targetPosition)* acceleration * delta;
		if (global_position.distance_squared_to(targetPosition) <= 125):
			targetPosition = null;

func state_spacing():
	
	if (spacingTimer <= 0):
		print("spacing!");
		spacing_helper();
	

func spacing_helper():
	spacingTimer = timeBetweenSpacing + randf_range(-timeBetweenSpacingVariation, timeBetweenSpacingVariation);
	
	var spacingRadius : int = 300;
	const minSpacingRadius : int = 300;
	const maxSpacingRadius : int = 400;
	
	
	var angle = global_position.angle_to_point(player.global_position);
	var neg = 1 if randf() > 0.5 else -1 
	
	## chance to change spacing radius
	if (randf() > 0.5):
		spacingRadius = randf_range(minSpacingRadius,maxSpacingRadius);
		

	
	var checkPriority 
	if global_position.distance_to(player.global_position) < spacingRadius + 50 || (randf() > 0.7):
		#print("Side!")
		checkPriority = [Vector2(-0.866, neg*0.5), Vector2(-1, 0), Vector2(-0.5, neg*0.866), Vector2(0, neg*1), Vector2(0.5, neg*0.866), Vector2(0.866, neg*0.5), Vector2(1, 0)];
	else:
		#print("Straight!")
		checkPriority = [Vector2(-1, 0), Vector2(-0.866, neg*0.5), Vector2(-0.5, neg*0.866), Vector2(0, neg*1), Vector2(0.5, neg*0.866), Vector2(0.866, neg*0.5), Vector2(1, 0)];
	var foundValid = false;
	for v :Vector2 in checkPriority:
		
		var candidate :Vector2 = v.rotated(angle) * spacingRadius + player.global_position;
		if playableArea.has_point(candidate) && (get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, candidate)).size() == 0):
			targetPosition = candidate;
			foundValid = true;
		else:
			candidate = Vector2(v.x, -v.y).rotated(angle) * spacingRadius + player.global_position;
			if playableArea.has_point(candidate) && (get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(global_position, candidate)).size() == 0):
				targetPosition = candidate;
				foundValid = true;
		if foundValid:
			break
	if !foundValid:
		pass
		#dash to center of map
	#print(targetPosition)

func state_get_off_me():
	pass
	
func state_pursuit():
	pass

func state_circle():
	pass

func state_default(delta : float):
	var dist_to_player = global_position.distance_to(player.global_position);
	circlingTimer = clampf(circlingTimer - delta, 0, circlingTimer);
	
	
	if (dist_to_player < getOffMeDistance || dist_to_player > pursuitDistance):
		circlingTimer = 0;
		if (dist_to_player < getOffMeDistance/2):
			dash(player.global_position.direction_to(global_position) * dashStrength);
		else:
			#var getOffMeFactor = ((pursuitDistance - getOffMeDistance)/2)+ getOffMeDistance;
			targetPosition = player.global_position + (player.global_position.direction_to(global_position) * (((pursuitDistance - getOffMeDistance)/2)+ getOffMeDistance));

	elif (dist_to_player > pursuitDistance):
		circlingTimer = 0;
		if (dist_to_player > pursuitDistance * 1.4):
			dash(global_position.direction_to(player.global_position) * dashStrength);
		else:
			targetPosition = player.global_position + (player.global_position.direction_to(global_position) * (((pursuitDistance - getOffMeDistance)/2)+ getOffMeDistance));

	else: #circle player

		if randf() > 0.9:
			circlingTimer = 0.5;
			circlingDirection *= -1;
			print("changedDir")
		
		var v = global_position.direction_to(player.global_position)
		targetPosition = global_position + (Vector2(v.y * circlingDirection, -v.x * circlingDirection) * 50)

func takeKnockback(value : Vector2):
	body.velocity = value;

func dash(vector : Vector2):
	body.velocity = vector;
	#dashTrail.dashAnim(0.1);
	
	
	
	
	
