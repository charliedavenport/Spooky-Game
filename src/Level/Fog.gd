@tool
extends Sprite2D

func _process(delta):
	if material == null:
		return
	material.set_shader_parameter("world_pos", global_position)
