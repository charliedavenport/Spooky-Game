extends PointLight2D
class_name VisibilityLight

var follow_target

func set_target(target: Node2D) -> void:
	follow_target = target
	self.global_position = follow_target.global_position
	self.texture_scale = follow_target.texture_scale
	self.visible = follow_target.visible
	follow_target.tree_exiting.connect(on_target_tree_exiting)


func _process(delta):
	if not follow_target:
		return
	self.global_position = follow_target.global_position
	self.visible = follow_target.visible


func on_target_tree_exiting() -> void:
	queue_free()
