# test_enemy_data.gd - Unit tests for EnemyData resource
extends GutTest


# ============================================
# Resource Loading Tests
# ============================================

func test_basic_enemy_data_loads() -> void:
	var data := preload("res://resources/enemies/enemy_basic.tres")
	assert_not_null(data, "Basic enemy data should load")
	assert_true(data is EnemyData, "Should be EnemyData resource")


func test_fast_enemy_data_loads() -> void:
	var data := preload("res://resources/enemies/enemy_fast.tres")
	assert_not_null(data, "Fast enemy data should load")
	assert_true(data is EnemyData, "Should be EnemyData resource")


func test_tank_enemy_data_loads() -> void:
	var data := preload("res://resources/enemies/enemy_tank.tres")
	assert_not_null(data, "Tank enemy data should load")
	assert_true(data is EnemyData, "Should be EnemyData resource")


# ============================================
# Property Validation Tests
# ============================================

func test_basic_enemy_has_valid_stats() -> void:
	var data: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	
	assert_gt(data.max_health, 0, "Health should be positive")
	assert_gt(data.speed, 0, "Speed should be positive")
	assert_gt(data.reward, 0, "Reward should be positive")
	assert_gt(data.damage_to_base, 0, "Damage to base should be positive")
	assert_gt(data.size, 0, "Size should be positive")


func test_fast_enemy_is_faster_than_basic() -> void:
	var basic: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var fast: EnemyData = preload("res://resources/enemies/enemy_fast.tres")
	
	assert_gt(fast.speed, basic.speed, "Fast enemy should be faster than basic")


func test_fast_enemy_has_less_health_than_basic() -> void:
	var basic: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var fast: EnemyData = preload("res://resources/enemies/enemy_fast.tres")
	
	assert_lt(fast.max_health, basic.max_health, "Fast enemy should have less health")


func test_tank_enemy_has_more_health_than_basic() -> void:
	var basic: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var tank: EnemyData = preload("res://resources/enemies/enemy_tank.tres")
	
	assert_gt(tank.max_health, basic.max_health, "Tank should have more health")


func test_tank_enemy_is_slower_than_basic() -> void:
	var basic: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var tank: EnemyData = preload("res://resources/enemies/enemy_tank.tres")
	
	assert_lt(tank.speed, basic.speed, "Tank should be slower")


func test_tank_gives_more_reward() -> void:
	var basic: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var tank: EnemyData = preload("res://resources/enemies/enemy_tank.tres")
	
	assert_gt(tank.reward, basic.reward, "Tank should give more reward")


# ============================================
# Shape Validation Tests
# ============================================

func test_enemy_shapes_are_valid() -> void:
	var basic: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var fast: EnemyData = preload("res://resources/enemies/enemy_fast.tres")
	var tank: EnemyData = preload("res://resources/enemies/enemy_tank.tres")
	
	assert_eq(basic.shape, 0, "Basic should be circle (0)")
	assert_eq(fast.shape, 1, "Fast should be triangle (1)")
	assert_eq(tank.shape, 2, "Tank should be hexagon (2)")


# ============================================
# Color Validation Tests
# ============================================

func test_enemies_have_distinct_colors() -> void:
	var basic: EnemyData = preload("res://resources/enemies/enemy_basic.tres")
	var fast: EnemyData = preload("res://resources/enemies/enemy_fast.tres")
	var tank: EnemyData = preload("res://resources/enemies/enemy_tank.tres")
	
	assert_ne(basic.color, fast.color, "Basic and Fast should have different colors")
	assert_ne(basic.color, tank.color, "Basic and Tank should have different colors")
	assert_ne(fast.color, tank.color, "Fast and Tank should have different colors")
