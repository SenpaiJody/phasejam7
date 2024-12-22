extends Node2D

class_name ShootModule;


var justShot : bool;
var cooldown : float; 

@export var shootCooldown = 0.5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	justShot = false;
	if (cooldown == 0 && Input.is_action_pressed("shoot")):
		shoot();
	
	cooldown = clampf(cooldown-delta, 0, cooldown);

func shoot():
	cooldown = shootCooldown;
	justShot = true;
	print("pew");
