extends Weapon

# --- Pistol Specific Branch Levels ---
var branch_a: int = 0
var branch_b: int = 0
var branch_c: int = 0

# --- Pistol Specific State ---
var shot_counter: int = 0
var beam_charge: float = 0.0
var is_holding_fire: bool = false

# --- Projectile Settings ---
var bullet_script = preload("res://src/weapon/script/Bullet.gd")

func _handle_input(delta: float) -> void:
	var firing = Input.is_action_pressed("fire")

	# Branch C tier 2+: charge beam logic
	if branch_c >= 2:
		if firing:
			beam_charge = min(beam_charge + delta * 2.0, 1.0)
			is_holding_fire = true
		else:
			if is_holding_fire and beam_charge > 0.3:
				_fire_beam()
			beam_charge = 0.0
			is_holding_fire = false
			
			if fire_timer <= 0.0:
				_fire_normal()
				fire_timer = fire_rate
		return

	if firing and fire_timer <= 0.0:
		_fire_normal()
		fire_timer = fire_rate

func _fire_normal() -> void:
	shot_counter += 1
	# 'player' is defined in Weapon.gd
	var extra = player.extra_projectiles if player else 0
	var total_shots = 1 + extra

	for i in range(total_shots):
		var angle_offset = 0.0
		if total_shots > 1:
			angle_offset = lerp(-0.2, 0.2, float(i) / float(total_shots - 1))
		_spawn_bullet(global_rotation + angle_offset)

	if branch_b >= 1 and shot_counter % 3 == 0:
		_fire_shockwave_projectile()

func _spawn_bullet(angle: float) -> void:
	var bullet = _create_bullet_instance()
	bullet.global_position = global_position
	bullet.rotation = angle

	var pierce = 1 if branch_a >= 1 else 0
	var bounces = 2 if branch_a >= 2 else 0
	var explode = true if branch_a >= 3 else false

	# 'damage', 'projectile_speed', and 'projectile_size' come from Weapon.gd
	bullet.setup(damage, projectile_speed, projectile_size, pierce, bounces, explode, false, false)
	get_tree().current_scene.add_child(bullet)

func _fire_shockwave_projectile() -> void:
	var bullet = _create_bullet_instance()
	bullet.global_position = global_position
	bullet.rotation = global_rotation
	
	var is_ring = branch_b >= 2
	var stun = branch_b >= 3
	
	bullet.setup(damage * 1.5, projectile_speed * 0.5, projectile_size * 2.5, 0, 0, false, is_ring, stun)
	get_tree().current_scene.add_child(bullet)

func _fire_beam() -> void:
	var bullet = _create_bullet_instance()
	bullet.global_position = global_position
	bullet.rotation = global_rotation
	
	var beam_dmg = damage * (2.0 + beam_charge * 3.0)
	var beam_size = projectile_size * (2.0 + beam_charge * 2.0) * (1.5 if branch_c >= 3 else 1.0)
	var burn = branch_c >= 3
	
	bullet.setup(beam_dmg, projectile_speed * 1.5, beam_size, 10, 0, false, false, false, burn)
	get_tree().current_scene.add_child(bullet)

func _create_bullet_instance() -> Node2D:
	var node := Node2D.new()
	node.set_script(bullet_script)
	return node
