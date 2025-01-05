extends Node2D

class_name BossBar

@export var titleLabel : RichTextLabel
@export var infillRed : TextureRect;
@export var InfillOrange : TextureRect;

const TOTAL_WIDTH = 468;

var progress : float; #out of 1
var previousProgress : float	; #out of 1

var delay = 0;
var isFilling = false;
var fillSpeed = 1;


func setName(name : String):
	titleLabel.text = name;
	progress = 0;
	previousProgress = 0;
	
func _process(delta: float) -> void:
	if progress != previousProgress:
		delay -= delta;
		if delay <= 0:
			if (previousProgress > progress):
				previousProgress = clamp(previousProgress + (-fillSpeed * delta), progress, 1)
			else:
				previousProgress = clamp(previousProgress + (fillSpeed * delta), 0, progress)
	if (progress > previousProgress):
		InfillOrange.size.x = 0;
		infillRed.size.x = previousProgress * TOTAL_WIDTH;
	else:
		InfillOrange.size.x = previousProgress *  TOTAL_WIDTH;
		infillRed.size.x = progress * TOTAL_WIDTH;
	

func setFill(percentage : float):
	if progress > percentage:
		delay = 0.5
	if (progress != percentage):
		progress = percentage
	
	
