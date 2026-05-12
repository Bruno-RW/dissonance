extends Node

#~ === === === SIGNALS === === === ~#
signal game_started
signal game_over(victory: bool)
signal level_up(new_level: int)
signal xp_changed(current: int, required: int)
signal timer_tick(elapsed: float)
signal enemy_killed(enemy_type: String)


#? === === === GAME STATE === === === ?#
enum GameState { MENU, PLAYING, PAUSED, LEVEL_UP, GAME_OVER }
var state: GameState = GameState.MENU


#? === === === SELECTION DATA === === === ?#
enum CharacterType { ASSAULT, SUPPRESSION, PRECISION, INFILTRATION }
enum LevelType { LEVEL1, LEVEL2, LEVEL3, LEVEL4 }

var selected_character: CharacterType = CharacterType.ASSAULT
var selected_level: LevelType = LevelType.LEVEL1

var character_scenes: Dictionary = {
	CharacterType.ASSAULT: preload("res://src/player/scene/varitants/Assault.tscn"),
	# CharacterType.SUPPRESSION: preload("res://src/player/SuppressionUnit.tscn"),
	# CharacterType.PRECISION: preload("res://src/player/PrecisionUnit.tscn"),
	# CharacterType.INFILTRATION: preload("res://src/player/InfiltrationUnit.tscn")
}

var level_scenes: Dictionary = {
	LevelType.LEVEL1: preload("res://src/level/scene/Level1.tscn"),
	# LevelType.LEVEL2: preload("res://src/level/scene/Level2.tscn"),
	# LevelType.LEVEL3: preload("res://src/level/scene/Level3.tscn")
}


#? === === === ROUND === === === ?#
var elapsed_time: float = 0.0
var MATCH_DURATION: float = 15.0 * 60.0   # 15 minutes

var player_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int = 100

var enemies_killed: int = 0
var coins_collected: int = 0


#? === === === DIFFICULTY === === === ?#
func get_difficulty_factor() -> float:
	return clamp(elapsed_time / MATCH_DURATION, 0.0, 1.0)

func get_enemy_hp_multiplier() -> float:
	return 1.0 + get_difficulty_factor() * 4.0

func get_enemy_speed_multiplier() -> float:
	return 1.0 + get_difficulty_factor() * 1.5

func get_enemy_damage_multiplier() -> float:
	return 1.0 + get_difficulty_factor() * 2.0

func get_xp_multiplier() -> float:
	return 1.0 + get_difficulty_factor() * 2.0


#? === === === EXPERIENCE (XP) === === === ?#
func add_xp(amount: int) -> void:
	current_xp += int(amount * get_xp_multiplier())
	emit_signal("xp_changed", current_xp, xp_to_next_level)

	while current_xp >= xp_to_next_level:
		current_xp -= xp_to_next_level
		player_level += 1
		xp_to_next_level = int(xp_to_next_level * 1.25)

		emit_signal("level_up", player_level)
		emit_signal("xp_changed", current_xp, xp_to_next_level)


#? === === === TIMER === === === ?#
func get_elapsed_formatted() -> String:
	var minute: int = int(elapsed_time) / 60
	var second: int = int(elapsed_time) % 60

	return "%02d:%02d" % [minute, second]


#? === === === LIFECYCLE === === === ?#
func start_game() -> void:
	elapsed_time = 0.0
	player_level = 1
	current_xp = 0
	xp_to_next_level = 100
	enemies_killed = 0
	coins_collected = 0
	state = GameState.PLAYING

	#? 1. Instance the selected Level
	var level_scene = level_scenes[selected_level]
	var level_instance = level_scene.instantiate()

	get_tree().root.add_child(level_instance)

	#? 2. Instance the selected Character
	var player_scene = character_scenes[selected_character]
	var player_instance = player_scene.instantiate()

	get_tree().root.add_child(player_instance)

	await get_tree().process_frame

	#? 3. Position player at center
	player_instance.global_position = level_instance.get_center()

	emit_signal("game_started")

func set_state(new_state: GameState) -> void:
	state = new_state

func _process(delta: float) -> void:
	if state != GameState.PLAYING: return

	elapsed_time += delta
	emit_signal("timer_tick", elapsed_time)

	# Boss should have been spawned at 15 min — handled by SpawnManager
	if elapsed_time >= MATCH_DURATION: pass


#? === === === CAMERA ZOOM === === === ?#
func get_camera_zoom() -> float:
	var t: float = get_difficulty_factor()
	return lerp(1.0, 1.0, t)
