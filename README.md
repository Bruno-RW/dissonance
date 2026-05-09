# DISSONANCE — MVP Integration Guide

## Project Structure

```
res://
├── scripts/
│   ├── GameManager.gd       ← Autoload singleton (global state, XP, timer)
│   ├── Arena.gd             ← Setor de Testes map (walls + floor)
│   ├── Player.gd            ← Movement, dash, HP, upgrade application
│   ├── Pistol.gd            ← Pistola de Pulso weapon + 3-branch evolution tree
│   ├── Bullet.gd            ← Universal projectile (pierce, ricochet, AoE, beam, burn)
│   ├── Enemy.gd             ← Base enemy (movement, damage, slow/stun/burn)
│   ├── EnemyFactory.gd      ← Creates minion_basic, minion_fast, minion_tank, eco, distorcao, boss
│   ├── SpawnManager.gd      ← Timed waves + milestone spawns (Eco/Distorção/Boss)
│   ├── UpgradeSystem.gd     ← Level-up logic, module pool, weapon tree interface
│   ├── HUD.gd               ← Timer, HP bar, XP bar, level, kill count, dash status
│   ├── LevelUpUI.gd         ← Two-panel upgrade choice overlay
│   ├── GameCamera.gd        ← Follows player, zoom-out driven by timer
│   ├── MainMenu.gd          ← Start / quit
│   └── GameOverUI.gd        ← Death / victory stats screen
└── scenes/
	└── GameScene.tscn       ← Main playable scene
```

---

## Step-by-step Setup in Godot 4.6

### 1. Register the Autoload
In **Project → Project Settings → Autoload**, add:
- **Name:** `GameManager`
- **Path:** `res://scripts/GameManager.gd`

### 2. Register Input Actions
Open `INPUT_AND_AUTOLOAD_SETUP.cfg` and copy the `[input]` block into your `project.godot`
(or use **Project → Project Settings → Input Map** to create them manually):

| Action      | Key / Button       |
|-------------|--------------------|
| `move_up`   | W / Arrow Up       |
| `move_down` | S / Arrow Down     |
| `move_left` | A / Arrow Left     |
| `move_right`| D / Arrow Right    |
| `dash`      | Space              |
| `fire`      | Left Mouse Button  |

### 3. Open GameScene.tscn
The scene is pre-wired. Hit **Play (F5)** — the game starts immediately.

> If Godot can't auto-load the `.tscn` because of missing sub-resources, open the scene
> in the editor and let Godot auto-fix the resource UIDs.

---

## Gameplay Systems Summary

### Timer & Camera Zoom
- Match runs **15 minutes**.
- Camera starts zoomed in (`zoom = 2.0`) and gradually pulls out to `1.0` at 15 min.
- This increases visible area, making it harder to dodge horde waves.

### Enemy Difficulty Scaling
All values interpolate over the 15-minute window:

| Stat           | Minute 0 | Minute 15 |
|----------------|----------|-----------|
| Enemy HP       | ×1.0     | ×5.0      |
| Enemy speed    | ×1.0     | ×2.5      |
| Enemy damage   | ×1.0     | ×3.0      |
| XP per kill    | ×1.0     | ×3.0      |
| Spawn interval | 2.5 s    | 0.6 s     |
| Enemies/wave   | 3        | 14        |

### Milestone Events
| Time    | Event                                      |
|---------|--------------------------------------------|
| 2.5 min | Eco (mini-boss) — blue, 400 HP base        |
| 5.0 min | Distorção Maior (stage boss) — purple, 1200 HP |
| 7.5 min | Eco                                        |
| 10 min  | Distorção Maior                            |
| 12.5 min| Eco                                        |
| 15 min  | **Manifestação da Ressonância** (final boss) |

### XP & Levelling
- XP required grows ×1.25 per level.
- On level-up: game **pauses**, level-up UI appears with two panels.

### Level-Up: Two-Panel Choice
**Panel 1 — Sintonização de Armas (weapon tree)**
Choose one branch node to advance (can mix branches freely):

| Branch           | T1                          | T2                        | T3                       |
|------------------|-----------------------------|---------------------------|--------------------------|
| A – Eco Reflexivo | Pierce +1 enemy            | Ricochet (2 bounces)      | Explode on final hit     |
| B – Onda de Choque| Every 3rd shot: slow blob  | Blob → shockwave ring AoE | Ring stuns 1s            |
| C – Feixe Contínuo| Fire rate +40%, size -20%  | Hold to charge beam       | Beam wider + burn DoT    |

**Panel 2 — Módulos Gerais**
4 random passive upgrades from the pool:
`dmg_up`, `speed_up`, `cd_up`, `aoe_up`, `hp_up`, `proj_up`

### Pistol – Pistola de Pulso
- Fires toward mouse cursor.
- Auto-fires while left mouse button held.
- Weapon node rotates to face mouse.

### Player – Unidade de Assalto
- WASD / arrows to move.
- **Space** to Dash (Hyperbaric Dash):
  - Invincible during dash (0.18s).
  - Leaves a vacuum trail that slows nearby enemies by 60% for 2s.
  - 5-second cooldown (reduced by Cooldown modules).

---

## Tuning Notes
All base values are exported properties — adjust them in the Godot Inspector without touching code:
- `Arena.gd`: `arena_width`, `arena_height`
- `Player.gd`: `base_max_hp`, `base_speed`, `dash_cooldown`
- `Pistol.gd`: `base_damage`, `base_fire_rate`
- `SpawnManager.gd`: `spawn_margin`, `_wave_interval`, `_min_wave_interval`
- `GameManager.gd`: `MATCH_DURATION`, all multiplier curves