extends Camera2D

# Follows the player smoothly.
# Zoom: starts at 2.0 (tight), gradually zooms out to 1.0 at 15 min.

@export var follow_speed: float = 8.0

var _player: Node2D = null

func _ready() -> void:
	await get_tree().process_frame
	_player = get_tree().get_first_node_in_group("player")
	make_current()

func _process(delta: float) -> void:
	if _player:
		global_position = global_position.lerp(_player.global_position, follow_speed * delta)

	# Zoom driven by game timer
	var target_zoom_val = GameManager.get_camera_zoom()
	var target_zoom = Vector2(target_zoom_val, target_zoom_val)
	zoom = zoom.lerp(target_zoom, 2.0 * delta)
