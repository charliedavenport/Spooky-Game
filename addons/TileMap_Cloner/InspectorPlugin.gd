extends EditorInspectorPlugin

func _can_handle(object):
	return object is TileMap

func _parse_begin(object):
	var btn = Button.new()
	btn.text = "Update TileMap"
	add_custom_control(btn)

