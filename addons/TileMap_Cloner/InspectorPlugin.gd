extends EditorInspectorPlugin

func _can_handle(object):
	return object is ClonableTileMap

func _parse_begin(object):
	var btn = Button.new()
	btn.text = "Update TileMap"
	if object.has_method("on_tilemap_refresh"):
		btn.pressed.connect(object.on_tilemap_refresh)
	add_custom_control(btn)

