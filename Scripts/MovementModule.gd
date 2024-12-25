extends Node2D;
class_name MovementModule;


@export var body : CharacterBody2D;
@export var animator : SpriteAnimator;
@export var dashTrail : DashTrail;

@export var speed : float = 300.0;
@export var acceleration : float = 2500.0;
@export var friction : float = 10.0;
@export var dashStrength = 1300;
@export var dashCooldown = 1;
var dashTimer = 0;

var movementDirection;

var allowMovement : bool = false;
var isMoving : bool = false;


func _process(delta: float) -> void:
	dashTimer = clampf(dashTimer - delta, 0, dashTimer);
	handleInput(delta);
	applyFriction(delta);
	isMoving = movementDirection != Vector2.ZERO;
	animator.isRunning = isMoving;

func applyFriction(delta : float):
	if (body.velocity.length() < 500*delta):
		body.velocity = Vector2.ZERO;
	body.velocity -= body.velocity * friction * delta;


func handleInput(delta : float):
	if (!allowMovement):
		isMoving = false;
		return;
	movementDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	
	if (dashTimer == 0 && movementDirection != Vector2.ZERO && Input.is_action_pressed("dash")):
		body.velocity = Vector2.ZERO;
		dash(movementDirection * dashStrength)
		dashTimer = dashCooldown;
	body.velocity +=  movementDirection* acceleration * delta;
	

func takeKnockback(value : Vector2):
	body.velocity = value;

func dash(vector : Vector2):
	body.velocity = vector;
	dashTrail.dashAnim(0.1);
	
	
	
	
	
