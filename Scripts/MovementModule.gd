extends Node2D;
class_name MovementModule;


@export var body : CharacterBody2D;
@export var animator : SpriteAnimator;
@export var dashTrail : DashTrail;

@export var speed : float = 300.0;
@export var acceleration : float = 2500.0;
@export var friction : float = 10.0;
@export var dashStrength = 2000;
@export var dashCooldown = 1;
@export var dashInvulnerabilityDuration = 0.4;
var dashCooldownTimer = 0;
var dashInvulnerabilityTimer = 0;

var movementDirection;

var allowMovement : bool = false;
var isMoving : bool = false;
var isDashing : bool = false;


func _process(delta: float) -> void:
	dashInvulnerabilityTimer = clampf(dashInvulnerabilityTimer - delta, 0, dashInvulnerabilityDuration);
	dashCooldownTimer = clampf(dashCooldownTimer - delta, 0, dashCooldownTimer);
	applyFriction(delta);
	handleInput(delta);
	isMoving = movementDirection != Vector2.ZERO;
	animator.isRunning = isMoving;
	
	if isDashing:
		dashInvulnerabilityTimer -= delta;
		
	#print(body.velocity)
	
	if isDashing && body.velocity.length() <= acceleration/friction:
		isDashing = false;
		#print("Distance Dashed: %f" % _testInitialDistance.distance_to(global_position));
		#print("Elapsed Time: %f"% _testTimer)

func applyFriction(delta : float):
	if (body.velocity.length() < 500*delta):
		body.velocity = Vector2.ZERO;
	body.velocity -= body.velocity * friction * delta;



func handleInput(delta : float):
	if (!allowMovement):
		isMoving = false;
		return;
	movementDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	
	if (dashCooldownTimer == 0 && movementDirection != Vector2.ZERO && Input.is_action_pressed("dash")):
		var v = movementDirection if body.velocity == Vector2.ZERO else body.velocity.normalized();
		dash(v * dashStrength)

	body.velocity +=  movementDirection* acceleration * delta;
	

func takeKnockback(value : Vector2):
	body.velocity = value;

func dash(vector : Vector2):
	isDashing = true;
	dashCooldownTimer = dashCooldown;
	dashInvulnerabilityTimer = dashInvulnerabilityDuration;
	body.velocity = vector;
	dashTrail.dashAnim(0.1);
	
	
	
	
