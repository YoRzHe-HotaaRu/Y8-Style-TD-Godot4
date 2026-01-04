# Enemy - Base enemy unit that follows a path
class_name Enemy
extends CharacterBody2D

signal died(enemy: Enemy, reward: int)
signal reached_end(enemy: Enemy)

# Data reference
var enemy_data: EnemyData

# Runtime state
var current_health: int = 100
var max_health: int = 100
var speed: float = 100.0
var reward: int = 10
var damage_to_base: int = 1

# Path following
var path_follow: PathFollow2D
var progress_ratio: float = 0.0

# Visual
@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = $HealthBar
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group("enemies")
	_update_health_bar()


func initialize(data: EnemyData, path: Path2D) -> void:
	print("Enemy: initialize called with data=", data.display_name if data else "NULL")
	enemy_data = data
	
	# Set stats from data
	max_health = data.max_health
	current_health = max_health
	speed = data.speed
	reward = data.reward
	damage_to_base = data.damage_to_base
	
	# Create path follow
	path_follow = PathFollow2D.new()
	path_follow.rotates = false
	path_follow.loop = false
	path.add_child(path_follow)
	print("Enemy: PathFollow2D created and added to path")
	
	# Setup visuals
	_generate_sprite(data)
	_setup_collision(data.size)
	_update_health_bar()
	print("Enemy: Sprite generated, position=", global_position)


func _physics_process(delta: float) -> void:
	if path_follow == null:
		return
	
	# Move along path
	path_follow.progress += speed * delta
	global_position = path_follow.global_position
	progress_ratio = path_follow.progress_ratio
	
	# Check if reached end
	if path_follow.progress_ratio >= 1.0:
		_on_reached_end()


func take_damage(amount: int) -> void:
	current_health -= amount
	_update_health_bar()
	
	# Play hit sound
	SoundManager.play_enemy_hit()
	
	# Visual feedback - flash white
	if sprite:
		var tween := create_tween()
		tween.tween_property(sprite, "modulate", Color.WHITE, 0.05)
		tween.tween_property(sprite, "modulate", Color(1, 1, 1, 1), 0.1)
	
	if current_health <= 0:
		_on_death()


func get_health_percentage() -> float:
	return float(current_health) / float(max_health)


func _on_death() -> void:
	SoundManager.play_enemy_death()
	SoundManager.play_coin_collect()
	EventBus.enemy_killed.emit(self, reward)
	died.emit(self, reward)
	_cleanup()


func _on_reached_end() -> void:
	SoundManager.play_life_lost()
	EventBus.enemy_reached_end.emit(self)
	reached_end.emit(self)
	_cleanup()


func _cleanup() -> void:
	if path_follow and is_instance_valid(path_follow):
		path_follow.queue_free()
	queue_free()


func _update_health_bar() -> void:
	if health_bar:
		health_bar.value = get_health_percentage() * 100
		health_bar.visible = current_health < max_health


# SVG texture paths
const ENEMY_TEXTURES := {
	0: "res://assets/enemies/enemy_basic.svg",
	1: "res://assets/enemies/enemy_fast.svg",
	2: "res://assets/enemies/enemy_tank.svg"
}


func _generate_sprite(data: EnemyData) -> void:
	if not sprite:
		return
	
	# Load SVG texture based on shape
	if ENEMY_TEXTURES.has(data.shape):
		var tex := load(ENEMY_TEXTURES[data.shape])
		if tex:
			sprite.texture = tex
			# Scale based on enemy size (48x48 SVG base)
			var scale_factor: float = data.size / 24.0
			sprite.scale = Vector2(scale_factor, scale_factor)


func _setup_collision(size: float) -> void:
	if collision_shape:
		var shape := CircleShape2D.new()
		shape.radius = size
		collision_shape.shape = shape
