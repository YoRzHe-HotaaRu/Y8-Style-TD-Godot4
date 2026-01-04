# LevelConfig - Static configuration for generating level waves
class_name LevelConfig
extends RefCounted

# Enemy data references (will be loaded)
static var enemy_basic: EnemyData
static var enemy_fast: EnemyData
static var enemy_tank: EnemyData

static var _loaded: bool = false


static func _ensure_loaded() -> void:
	if _loaded:
		return
	enemy_basic = load("res://resources/enemies/enemy_basic.tres")
	enemy_fast = load("res://resources/enemies/enemy_fast.tres")
	enemy_tank = load("res://resources/enemies/enemy_tank.tres")
	_loaded = true


static func get_waves_for_level(level: int) -> Array[WaveData]:
	_ensure_loaded()
	
	var waves: Array[WaveData] = []
	var wave_count: int = 3 + level  # Level 1 = 4 waves, Level 10 = 13 waves
	
	for wave_num in range(1, wave_count + 1):
		var wave := _create_wave(level, wave_num, wave_count)
		waves.append(wave)
	
	return waves


static func _create_wave(level: int, wave_num: int, total_waves: int) -> WaveData:
	var wave := WaveData.new()
	wave.wave_number = wave_num
	wave.delay_before_wave = 2.0 if wave_num == 1 else 3.0
	
	# Difficulty scaling factors
	var level_mult: float = 1.0 + (level - 1) * 0.3  # Level difficulty multiplier
	var wave_progress: float = float(wave_num) / float(total_waves)
	
	wave.enemy_datas = []
	wave.enemy_counts = []
	wave.spawn_intervals = []
	wave.delays_after_group = []
	
	# Wave composition based on level and wave progress
	match level:
		1:  # Tutorial - Only basic enemies
			_add_group(wave, enemy_basic, 3 + wave_num, 1.2, 2.0)
		
		2:  # Introduction to fast enemies
			_add_group(wave, enemy_basic, 3 + wave_num, 1.0, 2.0)
			if wave_num >= 3:
				_add_group(wave, enemy_fast, 2, 0.8, 1.5)
		
		3:  # More fast enemies
			_add_group(wave, enemy_basic, 4 + wave_num, 0.9, 1.5)
			_add_group(wave, enemy_fast, wave_num, 0.7, 2.0)
		
		4:  # Introduction to tank enemies
			_add_group(wave, enemy_basic, 5 + wave_num, 0.8, 1.5)
			_add_group(wave, enemy_fast, wave_num + 1, 0.6, 1.5)
			if wave_num >= 4:
				_add_group(wave, enemy_tank, 1, 2.0, 2.0)
		
		5:  # Mixed waves
			_add_group(wave, enemy_basic, 6 + wave_num, 0.7, 1.0)
			_add_group(wave, enemy_fast, wave_num + 2, 0.5, 1.5)
			_add_group(wave, enemy_tank, int(wave_num / 2), 1.5, 2.0)
		
		6:  # Faster spawns
			_add_group(wave, enemy_fast, 4 + wave_num, 0.5, 1.0)
			_add_group(wave, enemy_basic, wave_num * 2, 0.6, 1.0)
			_add_group(wave, enemy_tank, wave_num, 1.2, 1.5)
		
		7:  # Tank heavy
			_add_group(wave, enemy_tank, 2 + wave_num, 1.0, 1.5)
			_add_group(wave, enemy_fast, wave_num * 2, 0.4, 1.0)
			_add_group(wave, enemy_basic, wave_num * 2, 0.5, 1.0)
		
		8:  # Rush waves
			_add_group(wave, enemy_fast, 8 + wave_num * 2, 0.3, 0.5)
			_add_group(wave, enemy_tank, wave_num, 0.8, 1.0)
			_add_group(wave, enemy_basic, wave_num * 3, 0.4, 1.0)
		
		9:  # Endurance
			_add_group(wave, enemy_basic, 10 + wave_num * 2, 0.4, 0.5)
			_add_group(wave, enemy_fast, 5 + wave_num * 2, 0.3, 0.5)
			_add_group(wave, enemy_tank, wave_num + 2, 0.7, 1.0)
		
		10:  # Ultimate challenge
			_add_group(wave, enemy_tank, 3 + wave_num, 0.6, 0.5)
			_add_group(wave, enemy_fast, 8 + wave_num * 2, 0.25, 0.5)
			_add_group(wave, enemy_basic, 10 + wave_num * 3, 0.3, 0.5)
			_add_group(wave, enemy_tank, wave_num, 0.5, 1.0)
		
		_:  # Fallback
			_add_group(wave, enemy_basic, 5, 1.0, 2.0)
	
	return wave


static func _add_group(wave: WaveData, enemy: EnemyData, count: int, interval: float, delay: float) -> void:
	if count <= 0:
		return
	wave.enemy_datas.append(enemy)
	wave.enemy_counts.append(count)
	wave.spawn_intervals.append(interval)
	wave.delays_after_group.append(delay)


static func get_starting_currency(level: int) -> int:
	# More starting currency for harder levels
	return 100 + (level - 1) * 25


static func get_starting_lives(level: int) -> int:
	# Fewer lives for harder levels
	return max(5, 25 - level * 2)
