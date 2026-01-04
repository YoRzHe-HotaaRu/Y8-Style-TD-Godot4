# WaveManager - Handles enemy wave spawning
class_name WaveManager
extends Node

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()
signal enemy_spawned(enemy: Enemy)

# Configuration
@export var waves: Array[WaveData] = []
@export var enemy_path: Path2D
@export var enemy_container: Node2D

# State
var current_wave_index: int = -1
var is_wave_active: bool = false
var enemies_alive: int = 0
var spawning_in_progress: bool = false

# Preloaded resources
var enemy_scene: PackedScene
var enemy_data_basic: EnemyData
var enemy_data_fast: EnemyData
var enemy_data_tank: EnemyData


func _ready() -> void:
	enemy_scene = preload("res://scenes/enemies/enemy.tscn")
	
	# Preload enemy data
	enemy_data_basic = preload("res://resources/enemies/enemy_basic.tres")
	enemy_data_fast = preload("res://resources/enemies/enemy_fast.tres")
	enemy_data_tank = preload("res://resources/enemies/enemy_tank.tres")
	
	# Generate waves based on selected level
	_load_level_waves()


func _load_level_waves() -> void:
	# Clear existing waves
	waves.clear()
	current_wave_index = -1
	
	# Get waves from LevelConfig based on selected level
	var level: int = GameManager.selected_level
	waves = LevelConfig.get_waves_for_level(level)
	
	print("WaveManager: Loaded ", waves.size(), " waves for level ", level)


func start_next_wave() -> void:
	print("WaveManager: start_next_wave called. is_wave_active=", is_wave_active, " spawning=", spawning_in_progress)
	if is_wave_active or spawning_in_progress:
		print("WaveManager: Already active, returning")
		return
	
	current_wave_index += 1
	print("WaveManager: Current wave index=", current_wave_index, " total waves=", waves.size())
	
	if current_wave_index >= waves.size():
		# Check if all enemies are dead for victory
		if enemies_alive <= 0:
			all_waves_completed.emit()
			EventBus.all_waves_completed.emit()
		return
	
	_start_wave(current_wave_index)


func _start_wave(index: int) -> void:
	print("WaveManager: _start_wave called with index=", index)
	is_wave_active = true
	spawning_in_progress = true
	
	# Play wave start sound
	SoundManager.play_wave_start()
	
	var wave_data := waves[index]
	print("WaveManager: Wave data loaded, wave_number=", wave_data.wave_number, " groups=", wave_data.get_group_count())
	wave_started.emit(wave_data.wave_number)
	EventBus.wave_started.emit(wave_data.wave_number)
	
	# Wait before starting
	print("WaveManager: Waiting ", wave_data.delay_before_wave, " seconds before spawning")
	await get_tree().create_timer(wave_data.delay_before_wave).timeout
	
	# Spawn each enemy group
	for group_idx in range(wave_data.get_group_count()):
		var enemy_data := wave_data.get_enemy_data(group_idx)
		var count := wave_data.get_enemy_count(group_idx)
		var interval := wave_data.get_spawn_interval(group_idx)
		var delay := wave_data.get_delay_after_group(group_idx)
		
		print("WaveManager: Spawning group ", group_idx, " with ", count, " enemies")
		
		for i in range(count):
			_spawn_enemy(enemy_data)
			
			if i < count - 1:
				await get_tree().create_timer(interval).timeout
		
		# Delay after group
		await get_tree().create_timer(delay).timeout
	
	spawning_in_progress = false
	print("WaveManager: Wave spawning complete")


func _spawn_enemy(data: EnemyData) -> void:
	print("WaveManager: Spawning enemy - ", data.display_name if data else "NULL")
	if enemy_scene == null or enemy_path == null:
		push_error("WaveManager: Missing enemy_scene or enemy_path")
		print("WaveManager: ERROR - enemy_scene=", enemy_scene, " enemy_path=", enemy_path)
		return
	
	var enemy: Enemy = enemy_scene.instantiate()
	print("WaveManager: Enemy instantiated")
	
	# Add to container
	if enemy_container:
		enemy_container.add_child(enemy)
		print("WaveManager: Added to container")
	else:
		add_child(enemy)
		print("WaveManager: Added to self (no container)")
	
	# Initialize enemy
	enemy.initialize(data, enemy_path)
	print("WaveManager: Enemy initialized at ", enemy.global_position)
	
	# Track enemy
	enemies_alive += 1
	enemy.died.connect(_on_enemy_died)
	enemy.reached_end.connect(_on_enemy_reached_end)
	
	enemy_spawned.emit(enemy)
	EventBus.enemy_spawned.emit(enemy)


func _on_enemy_died(_enemy: Enemy, _reward: int) -> void:
	enemies_alive -= 1
	_check_wave_complete()


func _on_enemy_reached_end(_enemy: Enemy) -> void:
	enemies_alive -= 1
	_check_wave_complete()


func _check_wave_complete() -> void:
	if enemies_alive <= 0 and not spawning_in_progress:
		is_wave_active = false
		wave_completed.emit(current_wave_index + 1)
		EventBus.wave_completed.emit(current_wave_index + 1)
		
		# Check for all waves complete
		if current_wave_index >= waves.size() - 1:
			all_waves_completed.emit()
			EventBus.all_waves_completed.emit()


func get_current_wave() -> int:
	return current_wave_index + 1


func get_total_waves() -> int:
	return waves.size()


func is_all_waves_complete() -> bool:
	return current_wave_index >= waves.size() - 1 and enemies_alive <= 0 and not spawning_in_progress
