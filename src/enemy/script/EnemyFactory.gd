extends Node

#* Centralises enemy creation so SpawnManager only calls make_enemy(type).

const EnemyScript = preload("res://src/enemy/script/Enemy.gd")

enum EnemyType {
	MINION_BASIC,
	MINION_FAST,
	MINION_TANK,
	MINI_BOSS,
	STAGE_BOSS,
	FINAL_BOSS
}

static func make_enemy(type: EnemyType) -> CharacterBody2D:
	var e: CharacterBody2D = CharacterBody2D.new()
	e.set_script(EnemyScript)

	match type:
		EnemyType.MINION_BASIC:
			e.base_hp = 30.0
			e.base_speed = 70.0
			e.base_damage = 8.0
			e.xp_value = 10
			e.color = Color(0.6, 0.15, 0.15)
			e.body_size = Vector2(20, 20)
			e.enemy_type = "minion_basic"

		EnemyType.MINION_FAST:
			e.base_hp = 18.0
			e.base_speed = 130.0
			e.base_damage = 6.0
			e.xp_value = 12
			e.color = Color(0.8, 0.4, 0.1)
			e.body_size = Vector2(14, 14)
			e.enemy_type = "minion_fast"

		EnemyType.MINION_TANK:
			e.base_hp = 120.0
			e.base_speed = 40.0
			e.base_damage = 15.0
			e.xp_value = 20
			e.color = Color(0.4, 0.1, 0.4)
			e.body_size = Vector2(32, 32)
			e.enemy_type = "minion_tank"

		EnemyType.MINI_BOSS:   # Mini-boss: Eco (every 2.5 min)
			e.base_hp = 400.0
			e.base_speed = 90.0
			e.base_damage = 18.0
			e.xp_value = 80
			e.color = Color(0.2, 0.6, 0.9)
			e.body_size = Vector2(48, 48)
			e.enemy_type = "mini_boss"
			e.contact_damage_cooldown = 0.5

		EnemyType.STAGE_BOSS:   # Stage boss (every 5 min)
			e.base_hp = 1200.0
			e.base_speed = 60.0
			e.base_damage = 25.0
			e.xp_value = 200
			e.color = Color(0.7, 0.1, 0.7)
			e.body_size = Vector2(72, 72)
			e.enemy_type = "stage_boss"
			e.contact_damage_cooldown = 0.4

		EnemyType.FINAL_BOSS:   # Final boss: last enemy
			e.base_hp = 6000.0
			e.base_speed = 75.0
			e.base_damage = 30.0
			e.xp_value = 500
			e.color = Color(0.9, 0.0, 0.5)
			e.body_size = Vector2(96, 96)
			e.enemy_type = "final_boss"
			e.contact_damage_cooldown = 0.3

	return e
