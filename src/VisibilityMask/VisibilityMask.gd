extends TileMap
class_name VisibilityMask

const visibility_light_scene = preload("res://src/VisibilityMask/visibility_light.tscn")

@onready var lights = $Lights

func add_visibility_light(target) -> void:
	var vis_light = visibility_light_scene.instantiate()
	vis_light.set_target(target)
	lights.add_child(vis_light)
