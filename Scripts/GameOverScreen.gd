extends Node

class_name GameOverScreen;

@export var backdrop : TextureRect;
@export var GameOverText : RichTextLabel;
@export var brickTip : RichTextLabel;
@export var MenuBtn : Button;
@export var RetryBtn : Button;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MenuBtn.pressed.connect(func():GameManager.gamePhase = GameManager.GAMEPHASES.MAIN_MENU);
	RetryBtn.pressed.connect(GameManager.reloadPhase);

func show(showTip : bool) -> Signal:
	var tween : Tween = get_tree().create_tween()
	brickTip.visible = showTip;
	tween.tween_property(self, "modulate:a", 1, 1.5);
	return tween.finished;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
