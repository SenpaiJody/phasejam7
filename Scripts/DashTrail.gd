extends Node

class_name DashTrail

@export var AfterImage1 : Sprite2D;
@export var AfterImage2 : Sprite2D;
@export var AfterImage3 : Sprite2D;
@export var AfterImage4 : Sprite2D;

@export var fadeOutSpeed : float = 3;

@export var parent : Node2D;
@export var spriteAnimator: SpriteAnimator;

var isTrailActive = false;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (isTrailActive):
		reduceOpacity(delta);
		if (AfterImage4.modulate.a == 0):
			isTrailActive = false;
func dashAnim(timeBetweenImages : float):
	isTrailActive = true;
	#await get_tree().create_timer(timeBetweenImages).timeout
	AfterImage1.flip_h = spriteAnimator.sprite.flip_h;
	AfterImage1.global_position = parent.global_position;
	AfterImage1.modulate.a = 0.67;
	await get_tree().create_timer(timeBetweenImages).timeout
	AfterImage2.flip_h = spriteAnimator.sprite.flip_h;
	AfterImage2.global_position = parent.global_position;
	AfterImage2.modulate.a = 0.67;
	await get_tree().create_timer(timeBetweenImages).timeout
	AfterImage3.flip_h = spriteAnimator.sprite.flip_h;
	AfterImage3.global_position = parent.global_position;
	AfterImage3.modulate.a = 0.67;
	await get_tree().create_timer(timeBetweenImages).timeout
	AfterImage4.flip_h = spriteAnimator.sprite.flip_h;
	AfterImage4.global_position = parent.global_position;
	AfterImage4.modulate.a = 0.67;


func reduceOpacity(delta : float):
	AfterImage1.modulate.a -= delta * fadeOutSpeed;
	AfterImage2.modulate.a -= delta * fadeOutSpeed;
	AfterImage3.modulate.a -= delta * fadeOutSpeed;
	AfterImage4.modulate.a -= delta * fadeOutSpeed;

	
