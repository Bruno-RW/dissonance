extends CharacterBody2D

#? === === === STATS === === === ?#
@export var base_hp: float = 30.0
@export var base_speed: float = 70.0
@export var base_damage: float = 8.0
@export var xp_value: int = 10
@export var contact_damage_cooldown: float = 0.8
@export var enemy_type: String = "minion"

var max_hp: float
var current_hp: float
var speed: float
var damage: float


#? === === === STATUS EFFECTS === === === ?#
var slow_factor: float = 1.0
var slow_timer: float = 0.0
var is_stunned: bool = false
var stun_timer: float = 0.0
var burn_dps: float = 0.0
var burn_timer: float = 0.0

var contact_cd: float = 0.0


#? === === === VISUAL === === === ?#
var _rect: ColorRect
@export var color: Color = Color(0.8, 0.2, 0.2)
@export var body_size: Vector2 = Vector2(24, 24)

signal died(enemy_ref: Enemy)
var _is_dead: bool = false

func _ready() -> void:
	add_to_group("enemies")
	_apply_difficulty()
	current_hp = max_hp

	_rect = ColorRect.new()
	_rect.size = body_size
	_rect.position = -body_size / 2
	_rect.color = color
	add_child(_rect)

	# HP bar (background + fill)
	var bar_w: float = body_size.x + 4.0
	var bar_h: float = 4.0
	var bar_y: float = -body_size.y / 2 - 8.0
	var bar_bg = ColorRect.new()

	bar_bg.size = Vector2(bar_w, bar_h)
	bar_bg.position = Vector2(-bar_w / 2, bar_y)
	bar_bg.color = Color(0.15, 0.15, 0.15)
	add_child(bar_bg)

	var bar_fill = ColorRect.new()
	bar_fill.size = Vector2(bar_w, bar_h)
	bar_fill.position = Vector2(-bar_w / 2, bar_y)
	bar_fill.color = Color(0.2, 0.9, 0.3)
	add_child(bar_fill)
	
	set_meta("hp_bar_fill", bar_fill)
	set_meta("hp_bar_width", bar_w)

	# Collision
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()

	circle.radius = body_size.x / 2
	shape.shape = circle
	add_child(shape)

	collision_layer = 4
	collision_mask = 3

func _apply_difficulty() -> void:
	max_hp = base_hp * GameManager.get_enemy_hp_multiplier()
	speed = base_speed * GameManager.get_enemy_speed_multiplier()
	damage = base_damage * GameManager.get_enemy_damage_multiplier()

func _physics_process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING: return

	_update_status_effects(delta)
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_move_toward_player(delta)
	_check_contact_damage(delta)

func _move_toward_player(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player: return

	var dir = (player.global_position - global_position).normalized()
	velocity = dir * speed * slow_factor
	move_and_slide()

func _check_contact_damage(delta: float) -> void:
	contact_cd -= delta
	if contact_cd > 0.0: return

	var player = get_tree().get_first_node_in_group("player")
	var is_touching_player = player and global_position.distance_to(player.global_position) < body_size.x / 2 + 16.0

	if !is_touching_player: return

	if player.has_method("take_damage"):
		player.take_damage(damage)

	contact_cd = contact_damage_cooldown

func _update_status_effects(delta: float) -> void:
	if slow_timer > 0.0:
		slow_timer -= delta
		if slow_timer <= 0.0:
			slow_factor = 1.0
			
	if stun_timer > 0.0:
		stun_timer -= delta
		if stun_timer <= 0.0:
			is_stunned = false

	if burn_timer > 0.0:
		burn_timer -= delta
		take_damage(burn_dps * delta, false, false)
		if burn_timer <= 0.0:
			burn_dps = 0.0


#? === === === DAMAGE & DEATH === === === ?#
func take_damage(amount: float, stun: bool = false, burn: bool = false) -> void:
	if _is_dead: return

	current_hp -= amount
	_update_hp_bar()

	# Flash white — only for non-burn ticks to avoid excessive calls
	if amount > 0.5 and _rect:
		_rect.color = Color.WHITE
		await get_tree().create_timer(0.06).timeout

		if not is_instance_valid(self) or _is_dead: return
		_rect.color = color

	if stun:
		is_stunned = true
		stun_timer = 1.0

	if burn and burn_dps == 0.0:
		burn_dps = amount * 0.3
		burn_timer = 3.0

	if current_hp <= 0.0 and not _is_dead:
		_die()

func apply_slow(factor: float, duration: float) -> void:
	slow_factor = factor
	slow_timer = duration

func _die() -> void:
	_is_dead = true
	GameManager.add_xp(xp_value)
	GameManager.enemies_killed += 1
	emit_signal("died", self)
	GameManager.emit_signal("enemy_killed", enemy_type)
	queue_free()

func _update_hp_bar() -> void:
	if not has_meta("hp_bar_fill"): return

	var fill: ColorRect = get_meta("hp_bar_fill")
	var bar_w: float = get_meta("hp_bar_width")

	if not is_instance_valid(fill): return

	fill.size.x = bar_w * clamp(current_hp / max_hp, 0.0, 1.0)

	# Colour: green → yellow → red
	var r = get_hp_ratio()
	fill.color = Color(1.0 - r, r * 0.85, 0.1)


#? === === === UTIL === === === ?#
func get_hp_ratio() -> float:
	return current_hp / max_hp
