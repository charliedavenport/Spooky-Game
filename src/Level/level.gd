extends Node2D

@onready var player : Player = $LitViewport/LitLevel/TileMap/Player
@onready var torches = $LitViewport/LitLevel/TileMap/Torches
@onready var vis_mask : VisibilityMask = $VisibilityViewport/TileMap_VisMask
@onready var player_cam = $PlayerCamera
@onready var lit_viewport = $LitViewport

func _ready():
	player.torch_dropped.connect(on_torch_dropped)
	
	#player_cam.target = player
	$VisibilityViewport/TileMap_VisMask/PlayerCamera.target = player
	$DarkLevelViewport/DarkLevel/TileMap/PlayerCamera.target = player
	
	vis_mask.add_visibility_light(player.self_light)
	vis_mask.add_visibility_light(player.torch_light)
	for torch in torches.get_children():
		vis_mask.add_visibility_light(torch.torch_light)
	
	


func _input(event):
	lit_viewport.push_input(event)


func on_torch_dropped(torch: Torch) -> void:
	torches.add_child(torch)
	vis_mask.add_visibility_light(torch.get_node("TorchLight"))
