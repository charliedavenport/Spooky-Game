extends Camera2D

var target : Node2D

func _ready():
	$ColorRect.show()

func _process(delta):
	if not target:
		return
	global_position = target.global_position
