extends Node

# On level-up: emit signal with two panels:
#   1. Weapon Sintonização — pick one branch node to advance
#   2. General Modules     — pick one of 4 random passive modules
#
# The LevelUpUI reads these and presents the choice. Player confirms → apply.

signal upgrade_choice_ready(weapon_options: Array, module_options: Array)
signal upgrade_applied(panel: String, choice_id: String)

#? === === === UPGRADE OPTIONS === === === ?#
const ALL_MODULES: Array = [
	{"id": "dmg_up",   "name": "Amplificador de Dano",    "desc": "+20% dano de projéteis"},
	{"id": "speed_up", "name": "Acelerador Cinético",     "desc": "+15% velocidade de movimento"},
	{"id": "cd_up",    "name": "Sincronizador de Pulso",  "desc": "-10% cooldown de todas habilidades"},
	{"id": "aoe_up",   "name": "Campo de Expansão",       "desc": "+20% área de efeito"},
	{"id": "hp_up",    "name": "Reforço Biométrico",      "desc": "+25 HP máximo (cura 25 HP)"},
	{"id": "proj_up",  "name": "Multiplicador de Fluxo",  "desc": "+1 projétil por disparo"},
]

# var _rng: RandomNumberGenerator = RandomNumberGenerator.new()

func _ready() -> void:
	add_to_group("upgrade_system")
	# Defer so GameManager autoload is guaranteed available
	call_deferred("_connect_signals")

func _connect_signals() -> void:
	GameManager.connect("level_up", _on_level_up)

func _on_level_up(_new_level: int) -> void:
	GameManager.set_state(GameManager.GameState.LEVEL_UP)
	var weapon_opts = _build_weapon_options()
	var module_opts = _pick_modules(4)
	emit_signal("upgrade_choice_ready", weapon_opts, module_opts)

func _build_weapon_options() -> Array:
	var weapon = get_tree().get_first_node_in_group("weapon")
	if not weapon or not weapon.has_method("get_upgrade_tree"):
		return []
	var tree: Array = weapon.get_upgrade_tree()
	var opts: Array = []
	for branch_data in tree:
		var branch = branch_data["branch"]
		var tiers: Array = branch_data["tiers"]
		# Find the next unlockable tier
		for tier_data in tiers:
			if not tier_data["unlocked"]:
				opts.append({
					"id": "weapon_" + branch,
					"name": branch_data["name"] + " Nv." + str(tier_data["tier"]),
					"desc": tier_data["desc"],
					"branch": branch
				})
				break
	return opts

func _pick_modules(count: int) -> Array:
	var pool: Array = ALL_MODULES.duplicate()
	pool.shuffle()
	return pool.slice(0, min(count, pool.size()))


#? === === === APPLY UPGRADES === === === ?#
func apply_weapon_upgrade(choice_id: String) -> void:
	var branch = choice_id.replace("weapon_", "")
	var weapon = get_tree().get_first_node_in_group("weapon")
	if weapon and weapon.has_method("unlock_branch"):
		weapon.unlock_branch(branch)
	emit_signal("upgrade_applied", "weapon", choice_id)

func apply_module_upgrade(module_id: String) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("apply_general_upgrade"):
		player.apply_general_upgrade(module_id)
	emit_signal("upgrade_applied", "module", module_id)

func finish_upgrade() -> void:
	GameManager.set_state(GameManager.GameState.PLAYING)
