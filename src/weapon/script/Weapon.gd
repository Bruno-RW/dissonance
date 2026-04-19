extends Node2D
class_name Weapon

#? Shared signals and base stats
signal weapon_upgraded(branch: String, tier: int)

@export var base_damage: float = 10.0
@export var base_fire_rate: float = 0.5
# ... other base stats ...

var fire_timer: float = 0.0
@onready var player = get_parent()

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING: return
	
	# Shared: Follow Crosshair
	look_at(get_global_mouse_position())
	
	fire_timer -= delta
	_handle_input(delta)

func _handle_input(delta: float):
	# This is a "virtual" function. 
	# The children (Pistol/Shotgun) will override this.
	pass

func _create_bullet_node():
	var script = load("res://scripts/Bullet.gd")
	var node := Node2D.new()
	node.set_script(script)
	return node
