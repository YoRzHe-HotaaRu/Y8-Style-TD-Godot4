# test_combat_integration.gd - Integration tests for combat mechanics
extends GutTest

var enemy_scene: PackedScene
var tower_scene: PackedScene
var projectile_scene: PackedScene


func before_all() -> void:
	enemy_scene = preload("res://scenes/enemies/enemy.tscn")
	tower_scene = preload("res://scenes/towers/tower.tscn")
	projectile_scene = preload("res://scenes/projectiles/projectile.tscn")


func before_each() -> void:
	GameManager.reset_game()
	GameManager.start_game()


# ============================================
# Enemy Damage Tests
# ============================================

func test_enemy_takes_damage() -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	add_child_autofree(enemy)
	
	var enemy_data: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	# Create a dummy path
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(100, 0))
	add_child_autofree(path)
	
	enemy.initialize(enemy_data, path)
	await get_tree().process_frame
	
	var initial_health := enemy.current_health
	enemy.take_damage(20)
	
	assert_eq(enemy.current_health, initial_health - 20, "Enemy should lose 20 health")


func test_enemy_dies_at_zero_health() -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	add_child_autofree(enemy)
	
	var enemy_data: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(100, 0))
	add_child_autofree(path)
	
	enemy.initialize(enemy_data, path)
	await get_tree().process_frame
	
	# Track if died signal was emitted
	var died_signal_received := false
	enemy.died.connect(func(_e, _r): died_signal_received = true)
	
	# Deal lethal damage
	enemy.take_damage(enemy.max_health + 50)
	
	assert_true(died_signal_received, "Died signal should be emitted")


func test_enemy_health_percentage() -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	add_child_autofree(enemy)
	
	var enemy_data: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(100, 0))
	add_child_autofree(path)
	
	enemy.initialize(enemy_data, path)
	await get_tree().process_frame
	
	assert_eq(enemy.get_health_percentage(), 1.0, "Full health should be 100%")
	
	enemy.take_damage(enemy.max_health / 2)
	assert_almost_eq(enemy.get_health_percentage(), 0.5, 0.01, "Half health should be 50%")


# ============================================
# Tower Initialization Tests
# ============================================

func test_tower_initializes_with_data() -> void:
	var tower: Tower = tower_scene.instantiate()
	add_child_autofree(tower)
	
	var tower_data: TowerData = preload("res://resources/towers/tower_basic.tres")
	tower.initialize(tower_data)
	await get_tree().process_frame
	
	assert_eq(tower.damage, tower_data.damage, "Damage should match data")
	assert_eq(tower.range_radius, tower_data.range_radius, "Range should match data")
	assert_eq(tower.attack_speed, tower_data.attack_speed, "Attack speed should match data")


# ============================================
# Projectile Tests
# ============================================

func test_projectile_initializes() -> void:
	var projectile: Projectile = projectile_scene.instantiate()
	add_child_autofree(projectile)
	
	# Create a mock target position
	projectile.initialize(null, 25, 400.0, 0.0)
	await get_tree().process_frame
	
	assert_eq(projectile.damage, 25, "Damage should be set")
	assert_eq(projectile.speed, 400.0, "Speed should be set")


# ============================================
# Enemy Movement Tests
# ============================================

func test_enemy_moves_along_path() -> void:
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(0, 0))
	path.curve.add_point(Vector2(500, 0))
	add_child_autofree(path)
	
	var enemy: Enemy = enemy_scene.instantiate()
	add_child_autofree(enemy)
	
	var enemy_data: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	enemy.initialize(enemy_data, path)
	await get_tree().process_frame
	
	var initial_pos := enemy.global_position.x
	
	# Simulate movement for several frames
	for i in range(10):
		await get_tree().process_frame
	
	assert_gt(enemy.global_position.x, initial_pos, "Enemy should move along path")


# ============================================
# Tower Range Detection Tests
# ============================================

func test_tower_detects_enemy_in_range() -> void:
	var tower: Tower = tower_scene.instantiate()
	tower.global_position = Vector2(200, 200)
	add_child_autofree(tower)
	
	var tower_data: TowerData = preload("res://resources/towers/tower_basic.tres")
	tower.initialize(tower_data)
	await get_tree().process_frame
	
	# Create path and enemy
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2(200, 100))  # Start near tower
	path.curve.add_point(Vector2(200, 300))
	add_child_autofree(path)
	
	var enemy: Enemy = enemy_scene.instantiate()
	add_child_autofree(enemy)
	
	var enemy_data: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	enemy.initialize(enemy_data, path)
	
	# Wait for physics to update
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	# Enemy should be in tower's range
	var enemies := tower.get_enemies_in_range()
	assert_gt(enemies.size(), 0, "Tower should detect enemy in range")


# ============================================
# Combat Signal Tests
# ============================================

func test_enemy_kill_emits_reward() -> void:
	var reward_received := 0
	EventBus.enemy_killed.connect(func(_e, r): reward_received = r)
	
	var path := Path2D.new()
	path.curve = Curve2D.new()
	path.curve.add_point(Vector2.ZERO)
	path.curve.add_point(Vector2(100, 0))
	add_child_autofree(path)
	
	var enemy: Enemy = enemy_scene.instantiate()
	add_child_autofree(enemy)
	
	var enemy_data: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	enemy.initialize(enemy_data, path)
	await get_tree().process_frame
	
	enemy.take_damage(enemy.max_health + 10)
	
	assert_eq(reward_received, enemy_data.reward, "Reward should match enemy data")
