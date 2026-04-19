extends CanvasLayer

@onready var timer_label: Label = $TimerLabel
@onready var hp_bar: ProgressBar = $HPBar
@onready var xp_bar: ProgressBar = $XPBar
@onready var level_label: Label = $LevelLabel
@onready var kill_label: Label = $KillLabel
@onready var ability_label: Label = $AbilityLabel

func _ready() -> void:
	add_to_group("hud")
	GameManager.connect("timer_tick", _on_timer_tick)
	GameManager.connect("xp_changed", _on_xp_changed)
	GameManager.connect("level_up", _on_level_up)
	# HP connected after player spawns
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.connect("hp_changed", _on_hp_changed)
		player.connect("ability_used", _on_ability_used)
		player.connect("ability_ready", _on_ability_ready)
		hp_bar.max_value = player.max_hp
		hp_bar.value = player.current_hp

func _process(_delta: float) -> void:
	kill_label.text = "☠ %d" % GameManager.enemies_killed

func _on_timer_tick(_elapsed: float) -> void:
	timer_label.text = GameManager.get_elapsed_formatted()

func _on_hp_changed(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current

func _on_xp_changed(current: int, required: int) -> void:
	xp_bar.max_value = required
	xp_bar.value = current

func _on_level_up(new_level: int) -> void:
	level_label.text = "Nv. %d" % new_level

func _on_ability_used(cooldown: float) -> void:
	ability_label.text = "ability: %.1fs" % cooldown

func _on_ability_ready() -> void:
	ability_label.text = "ability: PRONTO"
