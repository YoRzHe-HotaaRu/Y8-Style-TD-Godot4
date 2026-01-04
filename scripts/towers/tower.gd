# Tower - Base tower that targets and attacks enemies
class_name Tower
extends StaticBody2D

signal enemy_targeted(enemy: Enemy)
signal attack_fired(target: Enemy)

# Data reference
var tower_data: TowerData

# Stats
var damage: int = 20
var attack_speed: float = 1.0
var range_radius: float = 150.0
var projectile_speed: float = 400.0
var targeting_mode: int = 0
var splash_radius: float = 0.0

# Runtime state
var enemies_in_range: Array[Enemy] = []
var current_target: Enemy = null
var can_attack: bool = true

# Scene references
var projectile_scene: PackedScene

# SVG texture paths
const BASE_TEXTURES := {
	0: "res://assets/towers/tower_basic_base.svg",
	1: "res://assets/towers/tower_sniper_base.svg",
	2: "res://assets/towers/tower_splash_base.svg"
}
const TURRET_TEXTURES := {
	0: "res://assets/towers/tower_basic_turret.svg",
	1: "res://assets/towers/tower_sniper_turret.svg",
	2: "res://assets/towers/tower_splash_turret.svg"
}

# Nodes
@onready var base_sprite: Sprite2D = $BaseSprite
@onready var turret_sprite: Sprite2D = $TurretSprite
@onready var range_area: Area2D = $RangeArea
@onready var range_collision: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var attack_timer: Timer = $AttackTimer
@onready var muzzle: Marker2D = $TurretSprite/Muzzle
@onready var range_indicator: Node2D = $RangeIndicator


func _ready() -> void:
	add_to_group("towers")
	
	# Connect signals
	range_area.body_entered.connect(_on_body_entered)
	range_area.body_exited.connect(_on_body_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	
	# Load projectile scene
	projectile_scene = preload("res://scenes/projectiles/projectile.tscn")


func initialize(data: TowerData) -> void:
	print("Tower: initialize called with ", data.display_name if data else "NULL")
	tower_data = data
	
	# Set stats
	damage = data.damage
	attack_speed = data.attack_speed
	range_radius = data.range_radius
	projectile_speed = data.projectile_speed
	targeting_mode = data.targeting_mode
	splash_radius = data.splash_radius
	
	# Setup attack timer
	attack_timer.wait_time = 1.0 / attack_speed
	attack_timer.start()
	
	# Setup range collision
	_setup_range(data.range_radius)
	
	# Load SVG textures
	_load_textures(data.shape)
	_update_range_indicator()
	print("Tower: Initialization complete")


func _load_textures(shape: int) -> void:
	# Load base texture (static, won't rotate)
	if BASE_TEXTURES.has(shape):
		var base_tex := load(BASE_TEXTURES[shape])
		if base_tex and base_sprite:
			base_sprite.texture = base_tex
			base_sprite.scale = Vector2(0.75, 0.75)  # Scale down 64x64 SVG
	
	# Load turret texture (will rotate to face target)
	if TURRET_TEXTURES.has(shape):
		var turret_tex := load(TURRET_TEXTURES[shape])
		if turret_tex and turret_sprite:
			turret_sprite.texture = turret_tex
			turret_sprite.scale = Vector2(0.75, 0.75)


func _process(_delta: float) -> void:
	_update_target()
	_look_at_target()


func _update_target() -> void:
	# Clean up invalid enemies
	enemies_in_range = enemies_in_range.filter(func(e): return is_instance_valid(e))
	
	# Get new target
	var new_target := Targeting.get_target(enemies_in_range, targeting_mode, global_position)
	
	if new_target != current_target:
		current_target = new_target
		if current_target:
			enemy_targeted.emit(current_target)


func _look_at_target() -> void:
	# Only rotate the turret, not the base!
	if current_target and is_instance_valid(current_target) and turret_sprite:
		var direction := current_target.global_position - global_position
		turret_sprite.rotation = direction.angle()


func _on_body_entered(body: Node2D) -> void:
	if body is Enemy and body not in enemies_in_range:
		enemies_in_range.append(body)
		if not body.died.is_connected(_on_enemy_died):
			body.died.connect(_on_enemy_died)


func _on_body_exited(body: Node2D) -> void:
	if body is Enemy:
		enemies_in_range.erase(body)
		if body == current_target:
			current_target = null


func _on_enemy_died(enemy: Enemy, _reward: int) -> void:
	enemies_in_range.erase(enemy)
	if enemy == current_target:
		current_target = null


func _on_attack_timer_timeout() -> void:
	if current_target and is_instance_valid(current_target):
		_fire_projectile()


func _fire_projectile() -> void:
	if projectile_scene == null or current_target == null:
		return
	
	# Play shooting sound
	SoundManager.play_tower_shoot()
	
	var projectile: Projectile = projectile_scene.instantiate()
	
	# Get projectile container from level
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_node("Projectiles"):
		level.get_node("Projectiles").add_child(projectile)
	else:
		get_tree().current_scene.add_child(projectile)
	
	# Get muzzle position
	var spawn_pos: Vector2
	if muzzle:
		spawn_pos = muzzle.global_position
	else:
		spawn_pos = global_position
	
	projectile.global_position = spawn_pos
	projectile.initialize(current_target, damage, projectile_speed, splash_radius)
	
	attack_fired.emit(current_target)


func _setup_range(radius: float) -> void:
	if range_collision and range_collision.shape:
		var shape := range_collision.shape as CircleShape2D
		if shape:
			shape.radius = radius


func _update_range_indicator() -> void:
	if range_indicator:
		range_indicator.set_script(preload("res://scripts/systems/range_drawer.gd"))
		range_indicator.set("radius", range_radius)
		range_indicator.queue_redraw()


func get_enemies_in_range() -> Array[Enemy]:
	return enemies_in_range
