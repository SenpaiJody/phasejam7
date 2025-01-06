extends Node2D

class_name BattleManager

const gameOverOverlayPrefab = preload("res://Prefabs/GameOveroverlay.tscn")



@export var tenmaSpawner : TenmaSpawner;
@export var camera : Camera2D;
@export var bossBar : BossBar
@export var hpBar : PippaHealthBar;

var bossTenma : Tenma;
var playerLoaded : bool = false

var isGameOver : bool = false;

var phase : int = -1;

var clonemaSpawnCooldown = 0;

var tenmapocalypseMaxCount = 20;
var tenmapocalypseCount = 20;

var phase3CloneSpawnTimer = 5;

var phase1Over = false;
var phase2Over = false;
var phase3Over = false;
func ready():
	Player.instance.onDeath.connect(onPlayerDeath);
	
	
func _process(delta: float) -> void:
	if (phase == 1):
		processPhase1()
	elif (phase == 2):
		#pass
		processPhase2()
	elif (phase == 3):
		processPhase3(delta);
	#print("%d / %d" % [tenmaSpawner.clonemaCount,tenmapocalypseCount]);
	
func initiatePhase1():
	phase = 1;
	phase1Over = false;
	Player.instance.hitModule.ignoreHits = false;
	SoundManager.playBGM(SoundManager.battle1Theme);
	#await get_tree().process_frame
	bossTenma = tenmaSpawner.spawnBossTenma();
	bossBar.setName("Tenma Maemi")
	Player.instance.onDeath.connect(onPlayerDeath);
	bossTenma.onDeath.connect(func():
		if (isGameOver):
			return
		Player.instance.hitModule.ignoreHits = true;
		GameManager.gamePausable = false;
		await get_tree().create_timer(3).timeout;
		GameManager.gamePhase = GameManager.GAMEPHASES.CUTSCENE2;
		phase1Over = true;
		)

func processPhase1():
	bossBar.setFill((float(bossTenma.hp))/float(bossTenma.maxHP));

func initiatePhase2():
	phase = 2;
	phase2Over = false;
	SoundManager.playBGM(SoundManager.battle1Theme);
	Player.instance.hitModule.ignoreHits = false;
	for i in range(3):
		#await get_tree().create_timer(0.1).timeout
		var t : Clonema = tenmaSpawner.spawnClonema();
		t.onDeath.connect(func():tenmapocalypseCount-=1, ConnectFlags.CONNECT_ONE_SHOT);
	bossBar.setName("The Tenmapocalypse")
	Player.instance.onDeath.connect(onPlayerDeath);

func processPhase2():
	
	bossBar.setFill((float(tenmapocalypseCount))/float(tenmapocalypseMaxCount));
	if !phase2Over && !isGameOver && tenmaSpawner.clonemaCount < min(4, tenmapocalypseCount):
		var t : Clonema = tenmaSpawner.spawnClonema();
		t.onDeath.connect(func():tenmapocalypseCount-=1, ConnectFlags.CONNECT_ONE_SHOT);
	if !phase2Over && !isGameOver && tenmapocalypseCount <= 0:
		Player.instance.hitModule.ignoreHits = true;
		GameManager.gamePausable = false;
		phase2Over = true;
		await get_tree().create_timer(3).timeout;
		GameManager.gamePhase = GameManager.GAMEPHASES.BATTLE3;
	
func initiatePhase3():
	SoundManager.playBGM(SoundManager.battle1Theme);
	Player.instance.hitModule.ignoreHits = false;
	phase3Over = false;
	phase = 3;
	bossTenma = tenmaSpawner.spawnBossTenma();
	bossBar.setName("Tenma Maemi, of Brick and Snow")
	Player.instance.onDeath.connect(onPlayerDeath);
	bossTenma.onDeath.connect(func():
		if (isGameOver):
			return
		Player.instance.hitModule.ignoreHits = true;
		GameManager.gamePausable = false;
		phase3Over = true;
		tenmaSpawner.clearAllClones();
		await get_tree().create_timer(3).timeout;
		GameManager.gamePhase = GameManager.GAMEPHASES.CUTSCENE3;
		)
func processPhase3(delta : float):
	bossBar.setFill((float(bossTenma.hp))/float(bossTenma.maxHP));
	phase3CloneSpawnTimer = clampf(phase3CloneSpawnTimer-delta, 0 , 5);
	if !phase3Over && phase3CloneSpawnTimer == 0 && !isGameOver && tenmaSpawner.clonemaCount < 2:
		tenmaSpawner.spawnClonema();
		phase3CloneSpawnTimer = 5;
		
		
		
func onPlayerDeath():
	isGameOver = true;
	tenmaSpawner.clearAllClones();
	#get_tree().create_timer(3).timeout.connect();
	camera.limit_top = -2000;
	camera.limit_bottom = 2000;
	camera.limit_right = 2000;
	camera.limit_left = -2000;
	bossBar.visible = false;
	hpBar.visible = false;
	GameManager.gamePausable = false;
	var goo: GameOverScreen = gameOverOverlayPrefab.instantiate();
	Player.instance.add_child(goo);
	Player.instance.move_child(goo, 0);
	
	goo.show(Player.instance.hitByBrickCounter > 1);
	var tween : Tween = create_tween();
	tween.tween_property(camera, "zoom", Vector2(3,3), 1.5);
	
