extends TileMap
class_name ClonableTileMap

@export_node_path("TileMap") var target : NodePath


func on_tilemap_refresh() -> void:
	print("refreshing tilemap...")
	if target.is_empty() or target == null:
		return
	
	var target_tilemap : TileMap = get_node(target)
	
	for layer_ind in range(target_tilemap.get_layers_count()):
		if not target_tilemap.is_layer_enabled(layer_ind):
			continue
		
		var layer_tile_positions = target_tilemap.get_used_cells(layer_ind)
		
		for tile_pos in layer_tile_positions:
			var cell_source = target_tilemap.get_cell_source_id(layer_ind, tile_pos)
			var cell_atlas_coord = target_tilemap.get_cell_atlas_coords(layer_ind, tile_pos)
			set_cell(layer_ind, tile_pos, cell_source, cell_atlas_coord)
	
	print("...done refreshing tilemap.")
