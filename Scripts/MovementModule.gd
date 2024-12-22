extends Node2D;
class_name MovementModule;


@export var body : CharacterBody2D;

var speed : float = 300.0;
var acceleration : float = 2500.0;
var friction : float = 10.0;

var movementDirection;

var allowMovement : bool = false;
var isMoving : bool = false;
var delta_isMoving;

func _process(delta: float) -> void:
	handleInput(delta);
	applyFriction(delta);
	delta_isMoving = isMoving;
	isMoving = movementDirection != Vector2.ZERO;

func applyFriction(delta : float):
	if (body.velocity.length() < 500*delta):
		body.velocity = Vector2.ZERO;
	body.velocity -= body.velocity * friction * delta;


func handleInput(delta : float):
	if (!allowMovement):
		isMoving = false;
		return;
	movementDirection = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	
	
	body.velocity +=  movementDirection* acceleration * delta;
	

func takeKnockback(value : Vector2):
	body.velocity = value;

func dash(vector : Vector2):
	body.velocity = vector;
	
	
