extends Area2D

var damage: float = 0
var speed: float = 0
var pierce_count: int = 0
var bounces: int = 0
var explode_on_impact: bool = false
var velocity: Vector2 = Vector2.ZERO

func setup(dmg, spd, size, pierce, bounce, explode, is_ring = false, stun = false):
	damage = dmg
	speed = spd
	pierce_count = pierce
	bounces = bounce
	explode_on_impact = explode
	
	# Visual Scaling
	$Sprite2D.scale = Vector2(size, size)
	$CollisionShape2D.scale = Vector2(size, size)
	
	# Calculate movement vector once
	velocity = Vector2.RIGHT.rotated(rotation) * speed

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		body.take_damage(damage)

		if pierce_count > 0: pierce_count -= 1
		else:
			if explode_on_impact: _spawn_explosion()
			queue_free()

	elif body is TileMapLayer: # Collision with Arena walls
		if bounces > 0:
			# Simple bounce logic: reflect velocity
			# (Requires a slightly more complex raycast or kinematic check)
			bounces -= 1

		else:
			queue_free()

func _spawn_explosion():
	# var exp = preload("res://src/weapon/scene/Explosion.tscn").instantiate()
	# exp.global_position = global_position
	# get_tree().current_scene.add_child(exp)
	print("Anomalia Detectada: Explosão rúnica disparada!")
