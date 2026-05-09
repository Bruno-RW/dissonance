extends CharacterBody2D
class_name BasePlayer

#? === === === SIGNALS === === === ?#
signal player_died
signal hp_changed(current: float, maximum: float)
signal ability_ready
signal ability_used(cooldown: float)


#? === === === BASE STATS === === === ?#
@export_group("Base Stats")
@export var base_max_hp: float = 100.0
@export var base_speed: float = 200.0


#? === === === RUNTIME STATS === === === ?#
var max_hp: float
var current_hp: float
var speed: float


#? === === === MODIFIERS === === === ?#
var damage_bonus: float = 0.0        # Flat bonus
var damage_multiplier: float = 1.0   # % bonus
var speed_multiplier: float = 1.0    # % bonus
var cooldown_reduction: float = 1.0  # (0.5 = 50% faster)
var area_multiplier: float = 1.0     # % bonus
var extra_projectiles: int = 0       # integer


#? === === === STATE === === === ?#
var is_invincible: bool = false
var _is_dead: bool = false
var ability_cd_timer: float = 0.0


#~ === === === BASE METHODS === === === ~#
func _ready() -> void:
	add_to_group("player")
	
	_apply_stats()
	current_hp = max_hp

func _apply_stats() -> void:
	max_hp = base_max_hp
	speed = base_speed * speed_multiplier

func _physics_process(delta: float) -> void:
	if _is_dead: return
	
	# Update timers
	if ability_cd_timer > 0:
		ability_cd_timer -= delta

		if ability_cd_timer <= 0:
			emit_signal("ability_ready")
	
	# Handle Input
	_handle_movement()
	_handle_ability_input()

func _handle_movement() -> void:
	var direction = _get_input_direction()
	velocity = direction * speed
	move_and_slide()

func _get_input_direction() -> Vector2:
	var input = Input\
		.get_vector(
			"move_left",
			"move_right",
			"move_up",
			"move_down"
		)\
		.normalized()
		
	return input

func _handle_ability_input() -> void:
	var should_activate = Input.is_action_just_pressed("ability") and ability_cd_timer <= 0
	if not should_activate: return

	activate_ability()


#~ === === === ABSTRACT METHODS === === === ~#
func activate_ability() -> void:
	# This base function acts as a placeholder
	print("Base Ability Activated - No unique effect defined.")

	# Example of starting a generic cooldown
	start_ability_cooldown(5.0)


#~ === === === UTIL === === === ~#
func start_ability_cooldown(duration: float) -> void:
	ability_cd_timer = duration * cooldown_reduction
	emit_signal("ability_used", ability_cd_timer)

func take_damage(amount: float) -> void:
	if is_invincible or _is_dead: return
	
	current_hp -= amount
	emit_signal("hp_changed", current_hp, max_hp)
	
	if current_hp <= 0: die()

func die() -> void:
	_is_dead = true
	emit_signal("player_died")
