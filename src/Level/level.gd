extends Node2D

@onready var player : Player = $LitViewport/LitLevel/TileMap/Player
@onready var torches = $LitViewport/LitLevel/TileMap/Torches
@onready var vis_mask : VisibilityMask = $VisibilityViewport/TileMap_VisMask
@onready var player_cam = $PlayerCamera
@onready var lit_viewport = $LitViewport

@onready var source_tilemap = $LitViewport/LitLevel/TileMap
@onready var clone_tilemaps = [
	$VisibilityViewport/TileMap_VisMask,
	$DarkLevelViewport/DarkLevel/TileMap
]

func _ready():
	player.torch_dropped.connect(on_torch_dropped)
	
	#player_cam.target = player
	$VisibilityViewport/TileMap_VisMask/PlayerCamera.target = player
	$DarkLevelViewport/DarkLevel/TileMap/PlayerCamera.target = player
	
	vis_mask.add_visibility_light(player.self_light)
	vis_mask.add_visibility_light(player.torch_light)
	for torch in torches.get_children():
		vis_mask.add_visibility_light(torch.torch_light)
	
	# clone the lit tilemap onto the other tilemaps
	for clone_target in clone_tilemaps:
		clone_tilemap(source_tilemap, clone_target)


func clone_tilemap(source: TileMap, target: TileMap) -> void:
	for layer_ind in range(source.get_layers_count()):
		var source_tiles = source.get_used_cells(layer_ind)
		for tile_coord in source_tiles:
			var source_id = source.get_cell_source_id(layer_ind, tile_coord )
			var atlas_coords = source.get_cell_atlas_coords(layer_ind, tile_coord)
			var alt_tile = source.get_cell_alternative_tile(layer_ind, tile_coord)
			target.set_cell(layer_ind, tile_coord, source_id, atlas_coords, alt_tile)


func _input(event):
	lit_viewport.push_input(event)


func on_torch_dropped(torch: Torch) -> void:
	torches.add_child(torch)
	vis_mask.add_visibility_light(torch.get_node("TorchLight"))
