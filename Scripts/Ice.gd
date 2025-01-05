extends Area2D




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(
		func(body:Node2D): 
			if body is Player:
				Player.instance.movementModule.doGliding = true;
				);
	body_exited.connect(
		func(body:Node2D): 
			if body is Player:
				Player.instance.movementModule.doGliding = false;
				);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
