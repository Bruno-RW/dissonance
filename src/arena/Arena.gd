extends Node2D

@export var arena_width: float = 1600.0
@export var arena_height: float = 1600.0

var _bounds: Rect2

func _ready() -> void:
	add_to_group("arena")
	_bounds = _calculate_bounds_from_tilemaps()
	if _bounds == Rect2():
		_bounds = Rect2(
			-arena_width * 0.5,
			-arena_height * 0.5,
			arena_width,
			arena_height,
		)

func get_bounds() -> Rect2:
	return _bounds

func get_center() -> Vector2:
	if _bounds != Rect2():
		return _bounds.position + _bounds.size * 0.5
		
	return Vector2(0, 0)

func _calculate_bounds_from_tilemaps() -> Rect2:
	var floor_layer := get_node_or_null("FloorLayer") as Node2D
	if floor_layer == null: return Rect2()

	if not floor_layer.has_method("get_used_rect"): return Rect2()

	var used_rect: Rect2 = floor_layer.get_used_rect()
	if used_rect == Rect2(): return Rect2()

	var cell_size: Vector2 = Vector2(16, 16)
	if floor_layer.has_property("cell_size"):
		cell_size = floor_layer.cell_size

	var top_left: Vector2 = floor_layer.position + used_rect.position * cell_size
	return Rect2(top_left, used_rect.size * cell_size)
