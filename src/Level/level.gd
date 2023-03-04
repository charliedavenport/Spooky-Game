extends Node2D

@onready var player : Player = $TileMap/Player
@onready var torches = $TileMap/Torches


func _ready():
	player.torch_dropped.connect(on_torch_dropped)

func on_torch_dropped(torch: Torch) -> void:
	torches.call_deferred("add_child", torch)
