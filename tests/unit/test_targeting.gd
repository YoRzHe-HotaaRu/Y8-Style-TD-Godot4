# test_targeting.gd - Unit tests for Targeting system
# Note: These tests use the get_target with untyped Array
# The Targeting class filters and casts internally
extends GutTest


# ============================================
# Get Target Strategy Tests with Real Enemy Data
# ============================================

func test_get_target_with_empty_array_returns_null() -> void:
	var result = Targeting.get_target([], Targeting.Strategy.FIRST, Vector2.ZERO)
	assert_null(result, "Should return null for empty array")


func test_targeting_strategy_first_is_zero() -> void:
	assert_eq(Targeting.Strategy.FIRST, 0, "FIRST strategy should be 0")


func test_targeting_strategy_last_is_one() -> void:
	assert_eq(Targeting.Strategy.LAST, 1, "LAST strategy should be 1")


func test_targeting_strategy_strongest_is_two() -> void:
	assert_eq(Targeting.Strategy.STRONGEST, 2, "STRONGEST strategy should be 2")


func test_targeting_strategy_weakest_is_three() -> void:
	assert_eq(Targeting.Strategy.WEAKEST, 3, "WEAKEST strategy should be 3")


func test_targeting_strategy_closest_is_four() -> void:
	assert_eq(Targeting.Strategy.CLOSEST, 4, "CLOSEST strategy should be 4")


# ============================================
# Static function visibility tests
# ============================================

func test_targeting_class_exists() -> void:
	assert_not_null(Targeting, "Targeting class should exist")


func test_get_target_function_exists() -> void:
	# Verify the function can be called with valid parameters
	var result = Targeting.get_target([], 0, Vector2.ZERO)
	assert_null(result, "Empty array should return null")

