extends Node

@export var ctrl : Control;
@export var black : TextureRect
@export var skipLabel : RichTextLabel

var skipProgress : float = 0;
var skipMessageOpacity : float = 4;	

func fadeSwitch(texture : Texture2D, fadeInDuration : float):
	var curr : TextureRect = ctrl.get_child(0);
	var next : TextureRect = ctrl.get_child(1);
	next.modulate.a = 0;
	curr.texture = next.texture;
	next.texture = texture;
	var tween : Tween = create_tween();
	tween.tween_property(next, "modulate:a", 1, fadeInDuration);
	return tween.finished;
	
func timer(time : float) -> Signal:
	return get_tree().create_timer(time).timeout;

func _custom_1_9() -> Signal:
	var tween : Tween = create_tween();
	var tween2 : Tween = create_tween();
	var child = ctrl.get_child(1)
	ctrl.get_child(0).texture = load("res://Art/cutscenes/background.png")
	tween.tween_property(child, "global_position:y", 500, 1.5);
	tween.finished.connect(func():child.global_position.y = 0)
	return tween2.finished

func fadeInBlack(time : float):
	var tween : Tween = create_tween();
	tween.tween_property(black, "modulate:a", 1, time);
	return tween.finished;

func fadeOutBlack(time : float):
	var tween : Tween = create_tween();
	tween.tween_property(black, "modulate:a", 0, time);
	return tween.finished;

func _ready() -> void:
	SoundManager.playBGM(SoundManager.battle1Theme);
	await fadeSwitch(load("res://Art/cutscenes/2-1.PNG"), 0.5);
	await timer(1);
	await fadeSwitch(load("res://Art/cutscenes/2-2-1.PNG"), 0.5);
	await timer(1);
	await fadeSwitch(load("res://Art/cutscenes/2-2-2.PNG"), 0.5);
	await timer(1);
	await fadeSwitch(load("res://Art/cutscenes/2-2-3.PNG"), 0.5);
	await timer(1);
	await fadeSwitch(load("res://Art/cutscenes/2-2-4.PNG"), 0.5);
	await timer(0.5);
	SoundManager.playSFX(SoundManager.snowShovelSFX);
	await fadeSwitch(load("res://Art/cutscenes/2-3.PNG"), 0.5);
	await timer(1);
	await fadeSwitch(load("res://Art/cutscenes/2-4.PNG"), 0.5);
	await timer(1);
	await fadeSwitch(load("res://Art/cutscenes/2-5.PNG"), 0.5);
	await timer(1.5);
	await fadeSwitch(load("res://Art/cutscenes/2-6.PNG"), 1);
	await timer(3);
	await fadeInBlack(2);
	GameManager.gamePhase = GameManager.GAMEPHASES.BATTLE2;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	skipMessageOpacity -= delta/2;
	if (skipMessageOpacity < 1):
		skipLabel.modulate.a = clampf(skipMessageOpacity, 0, 1)
	if Input.is_action_pressed("shoot"):
		skipProgress += delta;
	else:
		skipProgress = 0;
	if (skipProgress > 1.5):
		GameManager.gamePhase = GameManager.GAMEPHASES.BATTLE2;
		
