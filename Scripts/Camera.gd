extends Camera2D

@export var UILayer : CanvasLayer;

# Called every frame. 'delta' is the elapsed time since the previous frame.


func _process(delta: float) -> void:
	if (Player.instance != null):
		global_position = Player.instance.global_position;
