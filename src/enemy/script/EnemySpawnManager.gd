extends Node

# Reads elapsed time from GameManager and spawns enemies accordingly.
# Milestone schedule:
#   Every 2.5 min → mini-boss
#   Every 5.0 min → stage boss
#   At 15 min     → final boss

const EnemyFactoryScript = preload("res://src/enemy/script/EnemyFactory.gd")

@export var spawn_margin: float = 60.0   # pixels inset from arena edges when spawning enemies

var _wave_timer: float = 0.0
var _wave_interval: float = 2.5
var _min_wave_interval: float = 0.6

var _next_mini_boss_time: float = 2.5 * 60.0
var _next_stage_boss_time: float = 5.0 * 60.0
var _final_boss_spawned: bool = false

var _arena_bounds: Rect2 = Rect2(-800, -800, 1600, 1600)
var _factory: Node

func _ready() -> void:
	_factory = Node.new()
	_factory.set_script(EnemyFactoryScript)

	# Don't add to tree; use only as a namespace for make_enemy()
	await get_tree().process_frame
	var arena = get_tree().get_first_node_in_group("arena")
	if arena and arena.has_method("get_bounds"):
		_arena_bounds = arena.get_bounds()

func _process(delta: float) -> void:
	if GameManager.state != GameManager.GameState.PLAYING: return

	_handle_wave(delta)
	_handle_milestones()

func _handle_wave(delta: float) -> void:
	_wave_timer -= delta
	if _wave_timer > 0.0:return

	_wave_timer = _get_current_wave_interval()
	_spawn_wave()

func _get_current_wave_interval() -> float:
	var t = GameManager.get_difficulty_factor()
	return lerp(_wave_interval, _min_wave_interval, t)

func _spawn_wave() -> void:
	var t = GameManager.get_difficulty_factor()
	var base_count = int(lerp(3.0, 14.0, t))

	var types: Array = []
	if t < 0.2:
		types = [0, 0, 1]   # mostly basic, some fast

	elif t < 0.5:
		types = [0, 1, 2]

	else:
		types = [1, 2, 2]   # fast + tanks dominate

	for i in range(base_count):
		var type_idx = types[randi() % types.size()]
		_spawn_single(type_idx)

func _handle_milestones() -> void:
	var elapsed = GameManager.elapsed_time

	if elapsed >= _next_mini_boss_time:
		_next_mini_boss_time += 2.5 * 60.0
		_spawn_single(3)   # Mini boss

	if elapsed >= _next_stage_boss_time:
		_next_stage_boss_time += 5.0 * 60.0
		_spawn_single(4)   # Stage boss

	if elapsed >= 15.0 * 60.0 and not _final_boss_spawned:
		_final_boss_spawned = true
		_spawn_single(5)   # Final boss

func _spawn_single(type_index: int) -> void:
	# EnemyType enum: 0=BASIC 1=FAST 2=TANK 3=MINI_BOSS 4=STAGE_BOSS 5=FINAL_BOSS

	var enemy = _factory.make_enemy(type_index)
	enemy.global_position = _get_spawn_position()
	get_tree().current_scene.add_child(enemy)

func _get_spawn_position() -> Vector2:
	var bounds = _arena_bounds
	var safe_bounds = bounds.grow(-spawn_margin)

	if safe_bounds.size.x <= 0.0 or safe_bounds.size.y <= 0.0:
		safe_bounds = bounds

	return Vector2(
		randf_range(safe_bounds.position.x, safe_bounds.end.x),
		randf_range(safe_bounds.position.y, safe_bounds.end.y)
	)
