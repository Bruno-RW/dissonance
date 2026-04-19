extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Hide the standard Windows/Mac mouse cursor
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Make the sprite follow the mouse exactly
	global_position = get_global_mouse_position()
