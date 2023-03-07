@tool
extends EditorPlugin

const plugin_script = preload("res://addons/TileMap_Cloner/InspectorPlugin.gd")

var plugin

func _enter_tree():
	plugin = plugin_script.new()
	add_inspector_plugin(plugin)


func _exit_tree():
	remove_inspector_plugin(plugin)
