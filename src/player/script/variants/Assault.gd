extends BasePlayer

@export var dash_speed: float = 800.0
@export var dash_duration: float = 0.2

func _ready() -> void:
	super._ready()
	
	base_speed = 220.0 
	_apply_stats()

func activate_ability() -> void:
	_start_dash()

func _start_dash() -> void:
	if is_invincible: return
	
	is_invincible = true
	var original_velocity = velocity
	var dash_dir = _get_input_direction()
	
	# If not moving, dash forward (where the gun is pointing)
	if dash_dir == Vector2.ZERO:
		dash_dir = Vector2.RIGHT.rotated(get_local_mouse_position().angle())
	
	velocity = dash_dir * dash_speed
	start_ability_cooldown(5.0) 
	
	# End Dash after duration
	await get_tree().create_timer(dash_duration).timeout
	is_invincible = false
