extends Node2D
class_name Weapon

#~ Signal for the HUD/Upgrade menu to listen to
signal weapon_upgraded(branch: String, tier: int)

@export_group("Base Stats")
@export var base_damage: float = 12.0
@export var base_fire_rate: float = 0.4
@export var base_projectile_speed: float = 500.0
@export var base_projectile_size: float = 1.0

#~ Runtime stats
var damage: float
var fire_rate: float
var projectile_speed: float
var projectile_size: float

var fire_timer: float = 0.0

@onready var player: BasePlayer = get_parent()

#? === === === DEFAULT METHODS === === === ?#
func _ready() -> void:
	add_to_group("weapon")
	_recalculate_stats()

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING: return
	
	look_at(get_global_mouse_position())
	
	if fire_timer > 0:
		fire_timer -= delta
	
	#? Shooting logic
	_handle_input(delta)


#? === === === CUSTOM METHODS === === === ?#
func _recalculate_stats() -> void:
	damage = base_damage
	fire_rate = base_fire_rate
	projectile_speed = base_projectile_speed
	projectile_size = base_projectile_size
	
	#? Apply character stats
	if not player: return
	
	damage = (damage + player.damage_bonus) * player.damage_multiplier
	fire_rate *= player.cooldown_reduction # Lower is faster
	projectile_size *= player.area_multiplier


#? === === === ABSTRACT METHODS === === === ?#
func _handle_input(_delta: float) -> void: pass
