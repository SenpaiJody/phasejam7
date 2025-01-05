extends Area2D

class_name TenmaHitModule;

@export var invulnerabilityDuration : float = 1.5;
var invulnerabilityTimer : float;
var staggerTimer : float;
var ignoreHits : bool = false;;
signal getHit(s : Snowball);


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#monitoring = true;
	area_entered.connect(collide);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	invulnerabilityTimer = clampf(invulnerabilityTimer-delta, 0, invulnerabilityTimer);
	staggerTimer = clampf(staggerTimer-delta, 0, staggerTimer);
	#Player.instance.spriteAnimator.isStaggered = staggerTimer > 0;

func collide(area : Area2D):
	if (ignoreHits):
		return;
	if (area["isAlly"] != null && area.isAlly == true):
		if area.type == "Snowball":
			area.queue_free();
			var s : Snowball = area;
			getHit.emit(s);
