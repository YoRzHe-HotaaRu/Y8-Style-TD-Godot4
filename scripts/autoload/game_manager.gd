# GameManager - Global game state management
extends Node

enum GameState { MENU, PLAYING, PAUSED, WON, LOST }

# Game state
var current_state: GameState = GameState.MENU
var current_wave: int = 0
var total_waves: int = 5

# Player resources
var currency: int = 100:
	set(value):
		currency = max(0, value)
		EventBus.currency_changed.emit(currency)

var lives: int = 20:
	set(value):
		lives = max(0, value)
		EventBus.lives_changed.emit(lives)
		if lives <= 0 and current_state == GameState.PLAYING:
			_game_over(false)

# Constants
const STARTING_CURRENCY: int = 100
const STARTING_LIVES: int = 20

# Selected level (1-10)
var selected_level: int = 1


func _ready() -> void:
	_connect_signals()


func _connect_signals() -> void:
	EventBus.enemy_killed.connect(_on_enemy_killed)
	EventBus.enemy_reached_end.connect(_on_enemy_reached_end)
	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.all_waves_completed.connect(_on_all_waves_completed)


func start_game() -> void:
	reset_game()
	current_state = GameState.PLAYING


func reset_game() -> void:
	# Use level-specific starting values
	currency = LevelConfig.get_starting_currency(selected_level)
	lives = LevelConfig.get_starting_lives(selected_level)
	current_wave = 0
	current_state = GameState.MENU


func pause_game() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		get_tree().paused = true


func resume_game() -> void:
	if current_state == GameState.PAUSED:
		current_state = GameState.PLAYING
		get_tree().paused = false


func add_currency(amount: int) -> void:
	currency += amount


func spend_currency(amount: int) -> bool:
	if currency >= amount:
		currency -= amount
		return true
	return false


func can_afford(amount: int) -> bool:
	return currency >= amount


func lose_life(amount: int = 1) -> void:
	lives -= amount


func _on_enemy_killed(_enemy: Node2D, reward: int) -> void:
	add_currency(reward)


func _on_enemy_reached_end(_enemy: Node2D) -> void:
	lose_life(1)


func _on_wave_completed(wave_number: int) -> void:
	current_wave = wave_number
	SoundManager.play_wave_complete()


func _on_all_waves_completed() -> void:
	_game_over(true)


func _game_over(victory: bool) -> void:
	if victory:
		current_state = GameState.WON
		SoundManager.play_victory()
	else:
		current_state = GameState.LOST
		SoundManager.play_game_over()
	EventBus.game_over.emit(victory)
