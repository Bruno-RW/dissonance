extends Node2D

var _bounds: Rect2

func _ready() -> void:
	add_to_group("level")
	_update_bounds()

func get_bounds() -> Rect2: 
	return _bounds

func get_center() -> Vector2:
	return _bounds.get_center()


#? === === === UTIL === === === ?#
func _update_bounds() -> void:
	#? 1. Check for a dedicated "Bounds" node
	var bounds_node = get_node_or_null("Bounds")

	var has_bounds_node = bounds_node and "size" in bounds_node
	if has_bounds_node:
		_bounds = Rect2(bounds_node.position, bounds_node.size)
		return

	#? 2. Try to calculate from TileMaps
	_bounds = _calculate_bounds_from_tilemaps()
	if _bounds != Rect2(): return

	#? 3. Fallback: Calculate a bounding box that fits ALL children
	_bounds = _calculate_bounds_from_all_children()

func _calculate_bounds_from_tilemaps() -> Rect2:
	# Search for any TileMapLayer if "FloorLayer" isn't found
	var layer = get_node_or_null("FloorLayer")
	if not layer:
		for child in get_children():
			if child != TileMapLayer: continue

			layer = child
			break
	
	var is_invalid_layer = not layer or not layer.has_method("get_used_rect")
	if is_invalid_layer: return Rect2()

	var used_rect: Rect2 = layer.get_used_rect()
	if used_rect == Rect2(): return Rect2()

	# Godot 4 TileMapLayer cell size fix
	var cell_size: Vector2 = Vector2(16, 16)
	if layer.tile_set:
		cell_size = layer.tile_set.tile_size

	return Rect2(
		layer.global_position + used_rect.position * cell_size,
		used_rect.size * cell_size
	)

func _calculate_bounds_from_all_children() -> Rect2:
	var total_rect = Rect2()
	var first = true
	
	for child in get_children():
		if child != Node2D: continue

		if !first:
			total_rect = total_rect.expand(child.global_position)
			continue

		# Use (0,0) as a starting point if no children exist yet
		total_rect = Rect2(child.global_position, Vector2.ZERO)
		first = false

	
	# Add a small margin so the player isn't touching the very edge
	return total_rect.grow(50.0)
