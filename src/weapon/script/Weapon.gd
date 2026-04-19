extends Node2D
class_name Weapon

# Signal for the HUD/Upgrade menu to listen to
signal weapon_upgraded(branch: String, tier: int)

@export_group("Base Stats")
@export var base_damage: float = 12.0
@export var base_fire_rate: float = 0.4
@export var base_projectile_speed: float = 500.0
@export var base_projectile_size: float = 1.0

# Runtime stats (Used by Pistol.gd and other children)
var damage: float
var fire_rate: float
var projectile_speed: float
var projectile_size: float

var fire_timer: float = 0.0

# Reference to the character (Assault, Suppression, etc.)
@onready var player: BasePlayer = get_parent()

func _ready() -> void:
	add_to_group("weapon")
	_recalculate_stats()

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING: return
	
	# Common behavior: All weapons follow the crosshair/mouse
	look_at(get_global_mouse_position())
	
	if fire_timer > 0:
		fire_timer -= delta
	
	# Call the specific shooting logic defined in the child (Pistol, etc.)
	_handle_input(delta)

## Virtual function: Overridden by Pistol.gd, Shotgun.gd, etc.
func _handle_input(_delta: float) -> void:
	pass

func _recalculate_stats() -> void:
	damage = base_damage
	fire_rate = base_fire_rate
	projectile_speed = base_projectile_speed
	projectile_size = base_projectile_size
	
	#? Apply character stats
	if not player: return
	
	damage = (damage + player.damage_bonus) * player.damage_multiplier
	fire_rate *= player.cooldown_reduction # Lower is faster (cooldown reduction)
	projectile_size *= player.area_multiplier

## Utility function to spawn the bullet script node
func _instantiate_bullet_scene() -> Node2D:
	var bullet_scene = preload("res://src/weapon/scene/Bullet.tscn")
	return bullet_scene.instantiate()
