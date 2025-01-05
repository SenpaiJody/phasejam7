extends Area2D

class_name PippaHitModule;

@export var invulnerabilityDuration : float = 1.5;
var invulnerabilityTimer : float;
var staggerTimer : float;

signal onHit(area: Area2D);

@export var isInvulnerableCheatEnabled: bool = false;
@export var ignoreHits: bool = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#monitoring = true;
	area_entered.connect(collide);

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	invulnerabilityTimer = clampf(invulnerabilityTimer-delta, 0, invulnerabilityTimer);
	staggerTimer = clampf(staggerTimer-delta, 0, staggerTimer);
	Player.instance.spriteAnimator.isStaggered = staggerTimer > 0;

func collide(area : Area2D):	
	if (isInvulnerableCheatEnabled || ignoreHits):
		return
	if (area["isAlly"] != null && area.isAlly == false):
		if area.type == "Snowball" && invulnerabilityTimer == 0:
			area.queue_free();
			if (Player.instance.movementModule.dashInvulnerabilityTimer <=0):
				var s : Snowball = area;
				staggerTimer = 0.5;
				invulnerabilityTimer = invulnerabilityDuration;
				Player.instance.movementModule.takeKnockback(s.velocity.normalized() * 2)
				onHit.emit(area);
		elif area.type == "Brick" && invulnerabilityTimer <= 0.5:
			area.queue_free();
			var b : Brick = area;
			invulnerabilityTimer = invulnerabilityDuration;
			staggerTimer = 0.8;
			SoundManager.lowPassFade();
			SoundManager.playSFX(SoundManager.brickHitSFX, true);
			Player.instance.movementModule.takeKnockback(b.velocity.normalized() * 5)
			onHit.emit(area);
	#print(area.is_class("Snowball") || area.is_class("Brick"));
