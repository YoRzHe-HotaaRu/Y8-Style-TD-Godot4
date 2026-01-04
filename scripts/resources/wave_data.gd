# WaveData - Resource defining wave configuration
class_name WaveData
extends Resource

@export var wave_number: int = 1
@export var delay_before_wave: float = 3.0

# Simplified: Arrays index-matched for enemy groups
@export var enemy_datas: Array[EnemyData] = []
@export var enemy_counts: Array[int] = []
@export var spawn_intervals: Array[float] = []
@export var delays_after_group: Array[float] = []


func get_group_count() -> int:
	return enemy_datas.size()


func get_enemy_data(group_index: int) -> EnemyData:
	if group_index >= 0 and group_index < enemy_datas.size():
		return enemy_datas[group_index]
	return null


func get_enemy_count(group_index: int) -> int:
	if group_index >= 0 and group_index < enemy_counts.size():
		return enemy_counts[group_index]
	return 0


func get_spawn_interval(group_index: int) -> float:
	if group_index >= 0 and group_index < spawn_intervals.size():
		return spawn_intervals[group_index]
	return 1.0


func get_delay_after_group(group_index: int) -> float:
	if group_index >= 0 and group_index < delays_after_group.size():
		return delays_after_group[group_index]
	return 2.0

