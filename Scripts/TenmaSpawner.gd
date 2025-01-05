extends Node2D

class_name TenmaSpawner

@export var camera :Camera2D;

const clonema = preload("res://Prefabs/Clonema.tscn");
const bossTenma = preload("res://Prefabs/Tenma.tscn");


var scene : Node2D;
signal _clearAllClones;

var clonemaCount :int = 0;


const clonemaSpawnPoints = [Vector2(1600, 0),Vector2(1600, 200) ,Vector2(1600, 400) ,Vector2(1600, 600) ,Vector2(1600, 800) ,Vector2(1600, 950) ,Vector2(1200, 1200) ,Vector2(1000, 1200) ,Vector2(600, 1200) ,Vector2(400, 1200) ,Vector2(200, 1200) ,Vector2(-1200, -250) ,Vector2(-1200, -450) ,Vector2(-1200, -700) ,Vector2(-950, -1000) ,Vector2(-750, -1000) ,Vector2(-550, -1000) ,Vector2(-350, -1000) ,Vector2(-150, -1000) ,Vector2(50, -1000)]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scene = GameManager.currentScene if GameManager.currentScene != null else get_tree().root.get_child(0);

func spawnClonema():
	if (scene == null):
		scene = GameManager.currentScene;
	
	var c : Clonema = clonema.instantiate();
	
	var randomSpawn = randi_range(0,19);
	#c.isActive = false
	c.global_position = clonemaSpawnPoints[randomSpawn];
	
	if (randomSpawn <= 5):
		c.movementTarget = Vector2(1300,c.global_position.y);
	elif (randomSpawn <= 10):
		c.movementTarget = Vector2(c.global_position.x, 900);
	elif (randomSpawn <= 13):
		c.movementTarget = Vector2(-900,c.global_position.y);
	else:
		c.movementTarget = Vector2(c.global_position.x, -750);
	
	c.enterProgress = 0;

	clonemaCount +=1;
	c.onDeath.connect(func():clonemaCount -=1, ConnectFlags.CONNECT_ONE_SHOT);
	_clearAllClones.connect(c.die);
	
	scene.add_child(c)
	return c;
	
func randomizeClonemaStats(clonema : Clonema):
	clonema.autoAttackSpeed += randf_range(-0.2, 0.2);
	clonema.movementInterval += randf_range(-0.2, 0.2);
	clonema.moveSpeed += randi_range(-25, 25);

func spawnBossTenma():
	if (scene == null):
		scene = GameManager.currentScene;
	
	var t : Tenma = bossTenma.instantiate();
	scene.add_child(t);
	return t;
	
func clearAllClones():
	_clearAllClones.emit();
