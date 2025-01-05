extends Area2D

class_name Snowball

@export var isAlly : bool;
@export var speed : int = 500;
@export var lifetime : float;
@export var targetAngleOffset : float;
@export var curvature : float;
@export var velocity : Vector2;

@export var type : String = "Snowball";

var targetPosition;
var targetDistance;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func straight(origin : Vector2, target : Vector2, speed : float, lifetime : float, targetAngleOffset : float = 0):
	global_position = origin;
	self.lifetime = lifetime;
	
	velocity = origin.direction_to(target).rotated(targetAngleOffset) * speed;
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	lifetime-=delta;
	if (lifetime <= 0):
		queue_free();
	

func _physics_process(delta: float) -> void:
	global_position += velocity * speed * delta;
