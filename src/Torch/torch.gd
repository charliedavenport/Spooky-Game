extends Node2D
class_name Torch

@onready var torch_light = $TorchLight

var can_be_picked_up : bool = true

func _process(delta):
	var flame_sprite = $Sprite2D/Sprite2D
	flame_sprite.look_at(flame_sprite.global_position + Vector2.RIGHT)

func show_label() -> void:
	$Label.show()

func hide_label() -> void:
	$Label.hide()


