extends Node2D

@export var title : RichTextLabel

var startTitlePosition : float;
var velocity = 0;
var direction = 1;
var swapTimer = 0;

@export var mainPanel : VBoxContainer;
@export var startBtn : Button;
@export var levelSelectBtn : Button;
@export var optionsBtn : Button;

@export var levelSelectPanel : Panel;
@export var levelSelectLevel1Btn : Button;
@export var levelSelectLevel2Btn : Button;
@export var levelSelectLevel3Btn : Button;
@export var levelSelectBackBtn : Button;

@export var OptionsPanel : Panel;
@export var optionsSFXSlider : HSlider;
@export var optionsBGMSlider : HSlider;
@export var optionsNSFW : CheckButton;
@export var optionsInvincibilityCheat : CheckButton;
@export var optionsBackBtn : Button;

@export var nsfwTogglePNG : TextureRect;
@export var nsfwFlashPNG : TextureRect;
var flashInUse = false;
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startTitlePosition = title.global_position.y;
	SoundManager.playBGM(SoundManager.mainMenuTheme);
	startBtn.pressed.connect(func():GameManager.gamePhase = GameManager.GAMEPHASES.CUTSCENE1)
	levelSelectLevel1Btn.pressed.connect(func():GameManager.gamePhase = GameManager.GAMEPHASES.CUTSCENE1)
	levelSelectLevel2Btn.pressed.connect(func():GameManager.gamePhase = GameManager.GAMEPHASES.CUTSCENE2)
	levelSelectLevel3Btn.pressed.connect(func():GameManager.gamePhase = GameManager.GAMEPHASES.BATTLE3)
	
	levelSelectBtn.pressed.connect(showLevelSelect)
	optionsBtn.pressed.connect(showOptions)
	levelSelectBackBtn.pressed.connect(showMain)
	optionsBackBtn.pressed.connect(showMain);
	
	optionsBGMSlider.value_changed.connect(func(value : float): SoundManager.setBGMVolumeLinear(value));
	optionsSFXSlider.value_changed.connect(func(value : float): SoundManager.setSFXVolumeLinear(value));
	optionsNSFW.pressed.connect(func(): 
		if (flashInUse):
			optionsNSFW.button_pressed = false;
			return
		
		SoundManager.playSFX(SoundManager.cameraFlashSFX);
		flashInUse = true;
		nsfwTogglePNG.modulate.a = 1;
		nsfwFlashPNG.modulate.a = 1;
		var tween1 : Tween = get_tree().create_tween();
		tween1.tween_property(nsfwTogglePNG, "modulate:a", 0, 1);
		var tween2 : Tween = get_tree().create_tween();
		tween2.tween_property(nsfwFlashPNG, "modulate:a", 0, 0.5);
		await tween1.finished;
		optionsNSFW.button_pressed = false;
		flashInUse = false;
	)
	optionsInvincibilityCheat.pressed.connect(func(): 
		GameManager.isInvincibilityCheatEnabled = optionsInvincibilityCheat.button_pressed;
	)
	
	showMain();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	velocity = max(10,(25 - abs(title.global_position.y - startTitlePosition)));
	title.global_position += Vector2(0, velocity * delta * direction);
	swapTimer += delta;
	if (swapTimer >= 1 && abs(velocity) <= 10):
		direction *= -1
		swapTimer = 0;

func showMain():
	mainPanel.show();
	levelSelectPanel.hide();
	OptionsPanel.hide();
	
func showLevelSelect():
	mainPanel.hide();
	levelSelectPanel.show();
	OptionsPanel.hide();

func showOptions():
	mainPanel.hide();
	levelSelectPanel.hide();
	OptionsPanel.show();
	
	optionsBGMSlider.value = SoundManager.getBGMVolumeLinear();
	optionsSFXSlider.value = SoundManager.getSFXVolumeLinear();
	optionsInvincibilityCheat.button_pressed = GameManager.isInvincibilityCheatEnabled;
