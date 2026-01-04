# Projectile - Moves toward target and deals damage on hit
class_name Projectile
extends Area2D

# Properties
var target: Enemy
var damage: int = 20
var speed: float = 400.0
var splash_radius: float = 0.0

# Track last known target position for when target dies
var last_target_position: Vector2 = Vector2.ZERO
var has_target: bool = false

# Nodes
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visible_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if visible_notifier:
		visible_notifier.screen_exited.connect(_on_screen_exited)
	
	# Generate simple projectile visual
	_generate_sprite()


func initialize(target_enemy: Enemy, dmg: int, spd: float, splash: float = 0.0) -> void:
	target = target_enemy
	damage = dmg
	speed = spd
	splash_radius = splash
	
	if target and is_instance_valid(target):
		has_target = true
		last_target_position = target.global_position
		# Connect to track target death
		target.died.connect(_on_target_died)


func _physics_process(delta: float) -> void:
	# Update target position if target is still valid
	if has_target and target and is_instance_valid(target):
		last_target_position = target.global_position
	
	# Move toward last known position
	var direction := (last_target_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Rotate to face direction
	rotation = direction.angle()
	
	# Check if we've reached the target position (for when target is dead)
	if not has_target or not is_instance_valid(target):
		if global_position.distance_to(last_target_position) < 10:
			_deal_splash_damage()
			queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		if splash_radius > 0:
			_deal_splash_damage()
		else:
			body.take_damage(damage)
		queue_free()


func _deal_splash_damage() -> void:
	if splash_radius <= 0:
		return
	
	# Find all enemies in splash radius
	var enemies := get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy is Enemy and is_instance_valid(enemy):
			var dist := global_position.distance_to(enemy.global_position)
			if dist <= splash_radius:
				# Damage falls off with distance
				var falloff := 1.0 - (dist / splash_radius) * 0.5
				var splash_damage := int(damage * falloff)
				enemy.take_damage(splash_damage)


func _on_target_died(_enemy: Enemy, _reward: int) -> void:
	has_target = false
	# Continue to last known position and explode there


func _on_screen_exited() -> void:
	queue_free()


const PROJECTILE_TEXTURE := "res://assets/projectiles/projectile.svg"


func _generate_sprite() -> void:
	if not sprite:
		return
	
	# Load SVG texture
	var tex := load(PROJECTILE_TEXTURE)
	if tex:
		sprite.texture = tex
		sprite.scale = Vector2(1.0, 1.0)
	
	# Setup collision
	if collision_shape:
		var shape := CircleShape2D.new()
		shape.radius = 6.0
		collision_shape.shape = shape


