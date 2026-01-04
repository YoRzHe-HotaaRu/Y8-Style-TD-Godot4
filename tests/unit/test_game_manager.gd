# test_game_manager.gd - Unit tests for GameManager
extends GutTest

var game_manager_script: GDScript


func before_all() -> void:
	game_manager_script = preload("res://scripts/autoload/game_manager.gd")


func before_each() -> void:
	# Reset GameManager state before each test
	if GameManager:
		GameManager.reset_game()


# ============================================
# Currency Tests
# ============================================

func test_starting_currency_is_100() -> void:
	GameManager.reset_game()
	assert_eq(GameManager.currency, 100, "Starting currency should be 100")


func test_add_currency_increases_balance() -> void:
	GameManager.reset_game()
	var initial := GameManager.currency
	GameManager.add_currency(50)
	assert_eq(GameManager.currency, initial + 50, "Currency should increase by 50")


func test_spend_currency_decreases_balance() -> void:
	GameManager.reset_game()
	GameManager.currency = 100
	var result := GameManager.spend_currency(30)
	assert_true(result, "spend_currency should return true when affordable")
	assert_eq(GameManager.currency, 70, "Currency should decrease by 30")


func test_spend_currency_fails_when_insufficient() -> void:
	GameManager.reset_game()
	GameManager.currency = 20
	var result := GameManager.spend_currency(50)
	assert_false(result, "spend_currency should return false when insufficient")
	assert_eq(GameManager.currency, 20, "Currency should not change")


func test_can_afford_returns_true_when_sufficient() -> void:
	GameManager.currency = 100
	assert_true(GameManager.can_afford(50), "Should afford 50 with 100 currency")
	assert_true(GameManager.can_afford(100), "Should afford exact amount")


func test_can_afford_returns_false_when_insufficient() -> void:
	GameManager.currency = 30
	assert_false(GameManager.can_afford(50), "Should not afford 50 with 30 currency")


func test_currency_cannot_go_negative() -> void:
	GameManager.currency = -50
	assert_eq(GameManager.currency, 0, "Currency should clamp to 0")


# ============================================
# Lives Tests
# ============================================

func test_starting_lives_is_20() -> void:
	GameManager.reset_game()
	assert_eq(GameManager.lives, 20, "Starting lives should be 20")


func test_lose_life_decreases_lives() -> void:
	GameManager.reset_game()
	GameManager.lose_life(1)
	assert_eq(GameManager.lives, 19, "Lives should decrease by 1")


func test_lose_multiple_lives() -> void:
	GameManager.reset_game()
	GameManager.lose_life(5)
	assert_eq(GameManager.lives, 15, "Lives should decrease by 5")


func test_lives_cannot_go_negative() -> void:
	GameManager.lives = -10
	assert_eq(GameManager.lives, 0, "Lives should clamp to 0")


# ============================================
# Game State Tests
# ============================================

func test_initial_state_is_menu() -> void:
	GameManager.reset_game()
	assert_eq(GameManager.current_state, GameManager.GameState.MENU, "Initial state should be MENU")


func test_start_game_sets_playing_state() -> void:
	GameManager.start_game()
	assert_eq(GameManager.current_state, GameManager.GameState.PLAYING, "State should be PLAYING after start")


func test_reset_game_restores_defaults() -> void:
	GameManager.currency = 500
	GameManager.lives = 5
	GameManager.current_wave = 3
	GameManager.reset_game()
	
	assert_eq(GameManager.currency, 100, "Currency should reset to 100")
	assert_eq(GameManager.lives, 20, "Lives should reset to 20")
	assert_eq(GameManager.current_wave, 0, "Wave should reset to 0")


func test_pause_game_changes_state() -> void:
	GameManager.start_game()
	GameManager.pause_game()
	assert_eq(GameManager.current_state, GameManager.GameState.PAUSED, "State should be PAUSED")


func test_resume_game_returns_to_playing() -> void:
	GameManager.start_game()
	GameManager.pause_game()
	GameManager.resume_game()
	assert_eq(GameManager.current_state, GameManager.GameState.PLAYING, "State should return to PLAYING")


# ============================================
# Game Over Tests
# ============================================

func test_zero_lives_triggers_game_over() -> void:
	GameManager.start_game()
	# This should trigger game over internally
	GameManager.lives = 0
	assert_eq(GameManager.current_state, GameManager.GameState.LOST, "Should be LOST with 0 lives")
