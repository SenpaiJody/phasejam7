extends Node2D

class_name PippaHealthBar;

@export var pips : Array[TextureRect];
@export var area : Area2D;

var isMouseHovering = false;
var isPlayerNear = false;

var hpToDisplay : int : 
	get:
		if Player.instance != null:
			return Player.instance.hp;
		else:
			return 0;
var deltaHPToDisplay = -1;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for pip in pips:
		pip.pivot_offset = Vector2(16,7);
	
	area.monitoring = true;
	
	area.mouse_entered.connect(func():
		isMouseHovering = true;
		modulate.a = 0.5
		)
		
	area.mouse_exited.connect(func():
		isMouseHovering = false;
		if (!isPlayerNear):
			modulate.a = 1;
		)
		

func flash(node : TextureRect) -> Signal:
	var tween = get_tree().create_tween()
	tween.tween_property(node, "scale", Vector2(1.2,1.2), 0.15);
	tween.tween_property(node, "scale", Vector2(1,1), 0.15);
	node.modulate.r = 2;
	node.modulate.g = 2;
	var timer : SceneTreeTimer = get_tree().create_timer(0.3, false)
	timer.timeout.connect(
		func(): 
			node.modulate.r = 1; 
			node.modulate.g = 1;
			, ConnectFlags.CONNECT_ONE_SHOT);
	
	return timer.timeout;
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	if (hpToDisplay != deltaHPToDisplay):
		var HPProcessed : int = 0;
		
		for i in range(hpToDisplay):
			pips[i].visible = true;
		if hpToDisplay < deltaHPToDisplay:
			for i in range(hpToDisplay, deltaHPToDisplay):
				flash(pips[i]).connect(func():pips[i].visible = false)
	deltaHPToDisplay = hpToDisplay


func opacityIfHoveredorEntered():
	if (isMouseHovering || isPlayerNear):
		modulate.a = 0.5;
	else:
		modulate.a = 1;
