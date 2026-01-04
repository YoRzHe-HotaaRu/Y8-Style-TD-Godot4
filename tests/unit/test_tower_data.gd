# test_tower_data.gd - Unit tests for TowerData resource
extends GutTest


# ============================================
# Resource Loading Tests
# ============================================

func test_basic_tower_data_loads() -> void:
	var data := preload("res://resources/towers/tower_basic.tres")
	assert_not_null(data, "Basic tower data should load")
	assert_true(data is TowerData, "Should be TowerData resource")


func test_sniper_tower_data_loads() -> void:
	var data := preload("res://resources/towers/tower_sniper.tres")
	assert_not_null(data, "Sniper tower data should load")
	assert_true(data is TowerData, "Should be TowerData resource")


func test_splash_tower_data_loads() -> void:
	var data := preload("res://resources/towers/tower_splash.tres")
	assert_not_null(data, "Splash tower data should load")
	assert_true(data is TowerData, "Should be TowerData resource")


# ============================================
# Property Validation Tests
# ============================================

func test_towers_have_valid_costs() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	var splash: TowerData = preload("res://resources/towers/tower_splash.tres")
	
	assert_gt(basic.cost, 0, "Basic tower should have positive cost")
	assert_gt(sniper.cost, 0, "Sniper tower should have positive cost")
	assert_gt(splash.cost, 0, "Splash tower should have positive cost")


func test_sniper_costs_more_than_basic() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	
	assert_gt(sniper.cost, basic.cost, "Sniper should cost more than basic")


func test_sniper_has_higher_damage() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	
	assert_gt(sniper.damage, basic.damage, "Sniper should deal more damage")


func test_sniper_has_longer_range() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	
	assert_gt(sniper.range_radius, basic.range_radius, "Sniper should have longer range")


func test_sniper_attacks_slower() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	
	assert_lt(sniper.attack_speed, basic.attack_speed, "Sniper should attack slower")


func test_splash_tower_has_splash_radius() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var splash: TowerData = preload("res://resources/towers/tower_splash.tres")
	
	assert_eq(basic.splash_radius, 0.0, "Basic should have no splash")
	assert_gt(splash.splash_radius, 0.0, "Splash tower should have splash radius")


# ============================================
# Targeting Mode Tests
# ============================================

func test_towers_have_valid_targeting_modes() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	var splash: TowerData = preload("res://resources/towers/tower_splash.tres")
	
	# Valid range is 0-4 (First, Last, Strongest, Weakest, Closest)
	assert_between(basic.targeting_mode, 0, 4, "Basic targeting should be valid")
	assert_between(sniper.targeting_mode, 0, 4, "Sniper targeting should be valid")
	assert_between(splash.targeting_mode, 0, 4, "Splash targeting should be valid")


func test_sniper_targets_strongest() -> void:
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	assert_eq(sniper.targeting_mode, Targeting.Strategy.STRONGEST, "Sniper should target strongest")


func test_splash_targets_closest() -> void:
	var splash: TowerData = preload("res://resources/towers/tower_splash.tres")
	assert_eq(splash.targeting_mode, Targeting.Strategy.CLOSEST, "Splash should target closest")


# ============================================
# Shape Validation Tests
# ============================================

func test_towers_have_valid_shapes() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	var splash: TowerData = preload("res://resources/towers/tower_splash.tres")
	
	# Valid shapes are 0-2 (Square, Diamond, Octagon)
	assert_between(basic.shape, 0, 2, "Basic shape should be valid")
	assert_between(sniper.shape, 0, 2, "Sniper shape should be valid")
	assert_between(splash.shape, 0, 2, "Splash shape should be valid")


# ============================================
# Balance Tests
# ============================================

func test_tower_dps_is_balanced() -> void:
	var basic: TowerData = preload("res://resources/towers/tower_basic.tres")
	var sniper: TowerData = preload("res://resources/towers/tower_sniper.tres")
	var splash: TowerData = preload("res://resources/towers/tower_splash.tres")
	
	# Calculate DPS (Damage Per Second)
	var basic_dps := basic.damage * basic.attack_speed
	var sniper_dps := sniper.damage * sniper.attack_speed
	var splash_dps := splash.damage * splash.attack_speed
	
	# All towers should have reasonable DPS
	assert_gt(basic_dps, 0, "Basic DPS should be positive")
	assert_gt(sniper_dps, 0, "Sniper DPS should be positive")
	assert_gt(splash_dps, 0, "Splash DPS should be positive")
	
	# Sniper should have lower DPS but higher per-hit damage
	assert_gt(sniper.damage, basic_dps, "Sniper per-hit damage should be significant")
