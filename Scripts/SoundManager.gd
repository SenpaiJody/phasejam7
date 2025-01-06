extends Node2D

class_name SoundManager

@export var BGMPlayer : AudioStreamPlayer

const mainMenuTheme : AudioStream = preload("res://Resources/Runway.mp3");
const battle1Theme : AudioStream = preload("res://Resources/Concave.mp3");
const endTheme: AudioStream = preload("res://Resources/winter_calm.mp3")

const snowHitSFX : AudioStream = preload("res://Resources/snowHit.mp3");
const snowKillSFX : AudioStream = preload("res://Resources/snowKill.mp3");
const pippaDeathSFX : AudioStream = preload("res://Resources/PIPPA_DEATH.mp3");
const shootSFX : AudioStream = preload("res://Resources/shoot_SFX.mp3");
const brickHitSFX : AudioStream = preload("res://Resources/brick_hit_sfx.mp3");
const cameraFlashSFX : AudioStream = preload("res://Resources/camera-flash-204151.mp3");


const snowShovelSFX : AudioStream = preload("res://Resources/snow_shovel.mp3");


var sfxVolume : float = linear_to_db(0.15);
var sfxPlayerPool : Array = [];
@export var sfxPlayerContainer : Node;

static var instance : SoundManager;

var lowPassEffect : AudioEffectLowPassFilter;
var lowPassTween : Tween;




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mainMenuTheme.set_loop(true)
	battle1Theme.set_loop(true);
	instance = self;
	AudioServer.set_bus_effect_enabled(0,0, false);
	
	lowPassEffect = AudioServer.get_bus_effect(0,0);
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

static func playBGM(audiostream: AudioStream):
	if (audiostream == instance.BGMPlayer.stream):
		return;
	instance.BGMPlayer.stream = audiostream
	instance.BGMPlayer.play();

static func setBGMVolumeLinear(sliderValue : float):
	instance.BGMPlayer.volume_db = linear_to_db(sliderValue);
	
static func getBGMVolumeLinear() -> float:
	return db_to_linear(instance.BGMPlayer.volume_db);
	
static func setSFXVolumeLinear(sliderValue : float):
	instance.sfxVolume = linear_to_db(sliderValue);
	
static func getSFXVolumeLinear() -> float:

	return db_to_linear(instance.sfxVolume);
	
static func playSFX(audioStream : AudioStream, ignoreEffects : bool = false):
	var playerToUse: AudioStreamPlayer = null;
		 
	for player : AudioStreamPlayer in instance.sfxPlayerPool:
		if !player.playing:
			playerToUse = player;
			break;
	if playerToUse == null:
		playerToUse = instance.createNewSFXPlayer();

	playerToUse.bus = "EffectIgnored" if ignoreEffects else "Master";
	
	playerToUse.volume_db = instance.sfxVolume;
	playerToUse.stream = audioStream;
	playerToUse.play()

func createNewSFXPlayer() -> AudioStreamPlayer:
	var asp : AudioStreamPlayer = AudioStreamPlayer.new();
	sfxPlayerPool.append(asp);
	sfxPlayerContainer.add_child(asp);
	return asp;

static func lowPassFade():
	if (instance.lowPassTween != null && instance.lowPassTween.is_running()):
		instance.lowPassTween.kill();
	AudioServer.set_bus_effect_enabled(0,0, true);
	instance.lowPassEffect.cutoff_hz = 500;
	instance.lowPassTween = instance.get_tree().create_tween();
	instance.lowPassTween.tween_property(instance.lowPassEffect,"cutoff_hz", 10000, 1);
	instance.lowPassTween.finished.connect(func():
		AudioServer.set_bus_effect_enabled(0,0, false);
		)
