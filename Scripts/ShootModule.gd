extends Node2D

class_name ShootModule;

@export var animator : SpriteAnimator;

var justShot : bool;
var cooldown : float; 

@export var allowShoot : bool = false;
@export var shootCooldown = 0.5;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	justShot = false;
	
	if (allowShoot && cooldown == 0 && Input.is_action_pressed("shoot")):
		shoot();
	
	cooldown = clampf(cooldown-delta, 0, cooldown);

func shoot():
	cooldown = shootCooldown;
	justShot = true;
	animator.isShooting = true;
	get_tree().create_timer(0.25, false).timeout.connect(func():animator.isShooting = false);
	SoundManager.playSFX(SoundManager.shootSFX);
	SnowballSpawner.spawnSnowball(true, global_position, global_position + get_local_mouse_position() - Vector2(0,16), 3, 1.5);
	
