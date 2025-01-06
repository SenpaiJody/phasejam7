extends Node

@export var text : RichTextLabel
@export var skipLabel : RichTextLabel

var skipProgress : float = 0;
var skipMessageOpacity : float = 4;	


func _ready() -> void:
	SoundManager.playBGM(SoundManager.endTheme);
	await get_tree().create_timer(1);
	var tween : Tween = create_tween();
	tween.tween_property(text, "position:y", -1700, 60);
	await tween.finished
	GameManager.gamePhase = GameManager.GAMEPHASES.MAIN_MENU;

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
		GameManager.gamePhase = GameManager.GAMEPHASES.MAIN_MENU;
		
