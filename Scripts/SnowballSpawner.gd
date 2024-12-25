extends Node2D
class_name SnowballSpawner;
var snowballs : Array;

static var snowball : PackedScene = preload("res://Prefabs/snowball.tscn");
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
	_instance.get_tree().root.add_child(s);
