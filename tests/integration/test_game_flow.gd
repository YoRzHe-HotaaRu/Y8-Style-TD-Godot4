# test_integration_game_flow.gd - Integration tests for complete game flow
extends GutTest

var level_scene: PackedScene
var level_instance: Node2D


func before_all() -> void:
	level_scene = preload("res://scenes/main/level.tscn")


func before_each() -> void:
	GameManager.reset_game()
	GameManager.start_game()


func after_each() -> void:
	if level_instance and is_instance_valid(level_instance):
		level_instance.queue_free()
		level_instance = null


# ============================================
# Game Initialization Tests
# ============================================

func test_game_starts_with_correct_state() -> void:
	assert_eq(GameManager.current_state, GameManager.GameState.PLAYING)
	assert_eq(GameManager.currency, 100)
	assert_eq(GameManager.lives, 20)
	assert_eq(GameManager.current_wave, 0)


func test_level_scene_loads() -> void:
	level_instance = level_scene.instantiate()
	add_child_autofree(level_instance)
	
	assert_not_null(level_instance, "Level should instantiate")
	assert_true(level_instance.is_in_group("level"), "Level should be in 'level' group")


func test_level_has_required_nodes() -> void:
	level_instance = level_scene.instantiate()
	add_child_autofree(level_instance)
	await get_tree().process_frame
	
	assert_not_null(level_instance.get_node_or_null("EnemyPath"), "Should have EnemyPath")
	assert_not_null(level_instance.get_node_or_null("Towers"), "Should have Towers container")
	assert_not_null(level_instance.get_node_or_null("Enemies"), "Should have Enemies container")
	assert_not_null(level_instance.get_node_or_null("Projectiles"), "Should have Projectiles container")
	assert_not_null(level_instance.get_node_or_null("WaveManager"), "Should have WaveManager")
	assert_not_null(level_instance.get_node_or_null("PlacementSystem"), "Should have PlacementSystem")


# ============================================
# Wave System Integration Tests
# ============================================

func test_wave_manager_initializes() -> void:
	level_instance = level_scene.instantiate()
	add_child_autofree(level_instance)
	await get_tree().process_frame
	
	var wave_manager := level_instance.get_node("WaveManager") as WaveManager
	assert_not_null(wave_manager, "WaveManager should exist")
	assert_gt(wave_manager.get_total_waves(), 0, "Should have waves defined")


func test_wave_manager_has_path_reference() -> void:
	level_instance = level_scene.instantiate()
	add_child_autofree(level_instance)
	await get_tree().process_frame
	
	var wave_manager := level_instance.get_node("WaveManager") as WaveManager
	assert_not_null(wave_manager.enemy_path, "WaveManager should have path reference")


# ============================================
# Placement System Integration Tests
# ============================================

func test_placement_system_initializes() -> void:
	level_instance = level_scene.instantiate()
	add_child_autofree(level_instance)
	await get_tree().process_frame
	
	var placement := level_instance.get_node("PlacementSystem") as PlacementSystem
	assert_not_null(placement, "PlacementSystem should exist")
	assert_not_null(placement.tower_container, "Should have tower container reference")


# ============================================
# Currency Flow Tests
# ============================================

func test_spending_currency_updates_state() -> void:
	var initial := GameManager.currency
	GameManager.spend_currency(50)
	assert_eq(GameManager.currency, initial - 50)


func test_cannot_afford_expensive_tower() -> void:
	GameManager.currency = 30
	var tower_data: TowerData = preload("res://resources/towers/tower_basic.tres")
	assert_false(GameManager.can_afford(tower_data.cost), "Should not afford tower with insufficient funds")


# ============================================
# Lives Flow Tests
# ============================================

func test_losing_all_lives_ends_game() -> void:
	GameManager.lives = 1
	GameManager.lose_life(1)
	
	assert_eq(GameManager.lives, 0, "Lives should be 0")
	assert_eq(GameManager.current_state, GameManager.GameState.LOST, "Should be in LOST state")


# ============================================
# Scene Loading Tests
# ============================================

func test_enemy_scene_loads() -> void:
	var enemy_scene := preload("res://scenes/enemies/enemy.tscn")
	var enemy := enemy_scene.instantiate()
	add_child_autofree(enemy)
	
	assert_not_null(enemy, "Enemy should instantiate")
	assert_true(enemy is Enemy, "Should be Enemy type")


func test_tower_scene_loads() -> void:
	var tower_scene := preload("res://scenes/towers/tower.tscn")
	var tower := tower_scene.instantiate()
	add_child_autofree(tower)
	
	assert_not_null(tower, "Tower should instantiate")
	assert_true(tower is Tower, "Should be Tower type")


func test_projectile_scene_loads() -> void:
	var projectile_scene := preload("res://scenes/projectiles/projectile.tscn")
	var projectile := projectile_scene.instantiate()
	add_child_autofree(projectile)
	
	assert_not_null(projectile, "Projectile should instantiate")
	assert_true(projectile is Projectile, "Should be Projectile type")
