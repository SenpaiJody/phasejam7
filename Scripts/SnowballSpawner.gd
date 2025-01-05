extends Node2D
class_name SnowballSpawner;
var snowballs : Array;

static var snowball : PackedScene = preload("res://Prefabs/snowball.tscn");
static var brick : PackedScene = preload("res://Prefabs/brick.tscn");
static var theo : PackedScene = preload("res://Prefabs/theo.tscn");
# Called when the node enters the scene tree for the first time.

static var _instance : SnowballSpawner;


func _ready() -> void:
	_instance = self;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


static func spawnSnowball(isAlly: bool, origin : Vector2, target : Vector2, speed : float, lifetime : float, targetAngleOffset : float = 0):
	var s : Snowball= snowball.instantiate();
	s.isAlly = isAlly;
	s.straight(origin, target, speed, lifetime, targetAngleOffset);
	if (GameManager.currentScene != null):
		GameManager.currentScene.add_child(s);
	else:
		_instance.get_tree().root.get_child(0).add_child(s);

static func spawnBrick(origin : Vector2, target : Vector2, speed : float, lifetime : float, targetAngleOffset : float = 0):
	var s : Brick = brick.instantiate();
	s.isAlly = false;
	s.straight(origin, target, speed, lifetime, targetAngleOffset);
	if (GameManager.currentScene != null):
		GameManager.currentScene.add_child(s);
	else:
		_instance.get_tree().root.get_child(0).add_child(s);

static func spawnTheo(origin: Vector2, returnTarget : Node2D, target : Node2D,targetPosition : Vector2, speed : float, timeUntilFired : float, targetAngleOffset : float = 0) -> Signal:
	var t :Theo = theo.instantiate();
	t.target = target;
	t.returnTarget = returnTarget
	t.isAlly = true;
	t.straight(origin, targetPosition, speed, timeUntilFired, targetAngleOffset);
	if (GameManager.currentScene != null):
		GameManager.currentScene.add_child(t);
	else:
		_instance.get_tree().root.get_child(0).add_child(t);
	
	return t.onReturned;
