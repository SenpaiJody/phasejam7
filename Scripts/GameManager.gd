extends Node2D

class_name GameManager;

enum GAMEPHASES {NULL, MAIN_MENU, CUTSCENE1, BATTLE1, CUTSCENE2, BATTLE2, BATTLE3, VICTORY}
static var gamePhase : GAMEPHASES = GAMEPHASES.MAIN_MENU;
static var delta_gamePhase : GAMEPHASES = GAMEPHASES.NULL;
static var gameProgress : int= 3;

const BattleScene = preload("res://Levels/Battle.tscn");
const MainMenu = preload("res://Levels/MainMenu.tscn")
static var currentScene : Node2D;

static var gamePausable : bool 

static var gameScale : float = 1;


@export var fadeWipe : TextureRect;
@export var pauseMenu : Control;
@export var BGMVolumeSlider : HSlider;
@export var SFXVolumeSlider : HSlider;
@export var ResumeButton : Button;
@export var ReturnToMenuButton : Button;
@export var debugWriter : RichTextLabel;


static var isInvincibilityCheatEnabled = false;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.process_mode = Node.PROCESS_MODE_ALWAYS;	
	var factor = float(DisplayServer.screen_get_size().x)/float(get_tree().root.content_scale_size.x);
	get_tree().root.content_scale_factor = factor
	connectPauseMenu()
	
func connectPauseMenu():
	BGMVolumeSlider.value_changed.connect(func(value : float): SoundManager.setBGMVolumeLinear(value));
	SFXVolumeSlider.value_changed.connect(func(value : float): SoundManager.setSFXVolumeLinear(value));
	ResumeButton.pressed.connect(
	func():
		get_tree().paused = false;
		pauseMenu.visible = false;	
		)
	ReturnToMenuButton.pressed.connect(
	func(): 
		get_tree().paused = false;
		pauseMenu.visible = false;
		gamePhase = GAMEPHASES.MAIN_MENU;
		Player.instance.hitModule.ignoreHits = true;
	)

func fadeOut(duration : float) -> Signal:
	var tween : Tween = create_tween();
	tween.tween_property(fadeWipe, "modulate:a", 1, duration);
	return tween.finished;

func fadeIn(duration : float):
	var tween : Tween = get_tree().create_tween();
	tween.tween_property(fadeWipe, "modulate:a", 0, duration);
	return tween.finished;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleInput(delta);
	if gamePhase == GAMEPHASES.MAIN_MENU:
		if (delta_gamePhase != gamePhase):
			var fadeOutTime : float = 0.25 if delta_gamePhase == GAMEPHASES.NULL else 0.75
			gamePausable = false;
			delta_gamePhase = gamePhase
			await fadeOut(fadeOutTime);
			clearScene()
			mainMenuBegin();
			fadeIn(0.75);
		mainMenuProcess(delta);
	elif gamePhase == GAMEPHASES.CUTSCENE1:
		pass
	elif gamePhase == GAMEPHASES.BATTLE1:
		if (delta_gamePhase != gamePhase):
			gamePausable = true;
			delta_gamePhase = gamePhase
			await fadeOut(0.75);
			clearScene()
			battle1Begin();
			Player.instance.hitModule.isInvulnerableCheatEnabled = isInvincibilityCheatEnabled;
			fadeIn(0.75);
		battle1Process(delta);
	elif gamePhase == GAMEPHASES.CUTSCENE2:
		gamePausable = false;
		pass
	elif gamePhase == GAMEPHASES.BATTLE2:
		if (delta_gamePhase != gamePhase):
			gamePausable = true;
			delta_gamePhase = gamePhase
			await fadeOut(0.75);
			clearScene()
			battle2Begin();
			Player.instance.hitModule.isInvulnerableCheatEnabled = isInvincibilityCheatEnabled;
			fadeIn(0.75);
		battle2Process(delta);
	elif gamePhase == GAMEPHASES.BATTLE3:
		if (delta_gamePhase != gamePhase):
			gamePausable = true;
			delta_gamePhase = gamePhase
			await fadeOut(0.75);
			clearScene()
			battle3Begin();
			Player.instance.hitModule.isInvulnerableCheatEnabled = isInvincibilityCheatEnabled;
			fadeIn(0.75);
		#battle3Process(delta);
	elif gamePhase == GAMEPHASES.VICTORY:
		pass

func clearScene():
	if (currentScene != null):
		currentScene.queue_free();
	#var children = get_children();
	#for child in children:
		#if child.name != "SoundManager" && child.name !="FadeWipe":
			#child.queue_free();

func mainMenuBegin():
	currentScene = MainMenu.instantiate();
	
	add_child(currentScene);
@warning_ignore("unused_parameter")
func mainMenuProcess(delta : float):
	pass
	
func battle1Begin():
	var battleScene: BattleManager = BattleScene.instantiate();
	battleScene.process_mode = Node.PROCESS_MODE_PAUSABLE;
	currentScene = battleScene;
	add_child(battleScene);
	
	battleScene.initiatePhase1();
	
func battle1Process(delta : float):
	pass
	#if (!currentScene is BattleManager):
		#return;
	#var battleScene : BattleManager = currentScene;
	#
	#var s : String = "";
	#s += "battlemanager.tenmapocalypseCount : %d\n battlemanager.tenmapocalypseMaxCount : %d" % [battleScene.tenmapocalypseCount, battleScene.tenmapocalypseMaxCount];
	#s += ("\n\nProgress%f" % battleScene.bossBar.progress)
	#s += ("\nPreviousProgress: %f" % battleScene.bossBar.previousProgress)
	#s += ("\nDelay: %f" % battleScene.bossBar.delay)
	#s += "Tenma hp: %d / %d" % [battleScene.bossTenma.hp, battleScene.bossTenma.maxHP];
	#s += "Player hp: %d" % Player.instance.hp;
	#s += "\nisMouseHovered: %s" % battleScene.hpBar.isMouseHovering
	#s += "\nisPlayerEntered: %s" % battleScene.hpBar.isPlayerNear
	
	#debugWriter.text = s;

func handleInput(delta : float) -> void:
	if gamePausable && Input.is_action_pressed("pause"):
		pauseMenu.visible = true;
		get_tree().paused = true;
		BGMVolumeSlider.value = SoundManager.getBGMVolumeLinear();
		SFXVolumeSlider.value = SoundManager.getSFXVolumeLinear();
	
	

func battle2Begin():
	var battleScene: BattleManager = BattleScene.instantiate();
	battleScene.process_mode = Node.PROCESS_MODE_PAUSABLE;
	currentScene = battleScene;
	add_child(battleScene);
	
	battleScene.initiatePhase2();
	
func battle2Process(delta : float):
	pass
	#if (!currentScene is BattleManager):
		#return;
	#var battleScene : BattleManager = currentScene;
	#
	#var s : String = "";
	##s += "battlemanager.tenmapocalypseCount : %d\n battlemanager.tenmapocalypseMaxCount : %d" % [battleScene.tenmapocalypseCount, battleScene.tenmapocalypseMaxCount];
	##s += ("\n\nProgress%f" % battleScene.bossBar.progress)
	##s += ("\nPreviousProgress: %f" % battleScene.bossBar.previousProgress)
	##s += ("\nDelay: %f" % battleScene.bossBar.delay)
	#s += "Player hp: %d" % Player.instance.hp;
	#s += "\nisMouseHovered: %s" % battleScene.hpBar.isMouseHovering
	#s += "\nisPlayerEntered: %s" % battleScene.hpBar.isPlayerNear
	#s += "\narea.global_position: %s" % battleScene.hpBar.area.global_position;
	#debugWriter.text = s;

func battle3Begin():
	var battleScene: BattleManager = BattleScene.instantiate();
	battleScene.process_mode = Node.PROCESS_MODE_PAUSABLE;
	currentScene = battleScene;
	add_child(battleScene);
	
	battleScene.initiatePhase3();

static func reloadPhase():
	delta_gamePhase = GAMEPHASES.NULL;
