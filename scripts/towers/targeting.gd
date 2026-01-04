# Targeting - Static utility class for tower targeting strategies
class_name Targeting
extends RefCounted

enum Strategy { FIRST, LAST, STRONGEST, WEAKEST, CLOSEST }


static func get_target(enemies: Array, strategy: int, tower_position: Vector2 = Vector2.ZERO) -> Enemy:
	if enemies.is_empty():
		return null
	
	# Filter out invalid enemies
	var valid_enemies: Array[Enemy] = []
	for enemy in enemies:
		if is_instance_valid(enemy) and enemy is Enemy:
			valid_enemies.append(enemy)
	
	if valid_enemies.is_empty():
		return null
	
	match strategy:
		Strategy.FIRST:
			return _get_first(valid_enemies)
		Strategy.LAST:
			return _get_last(valid_enemies)
		Strategy.STRONGEST:
			return _get_strongest(valid_enemies)
		Strategy.WEAKEST:
			return _get_weakest(valid_enemies)
		Strategy.CLOSEST:
			return _get_closest(valid_enemies, tower_position)
		_:
			return _get_first(valid_enemies)


static func _get_first(enemies: Array[Enemy]) -> Enemy:
	# First = furthest along the path (highest progress_ratio)
	var best: Enemy = null
	var best_progress: float = -1.0
	
	for enemy in enemies:
		if enemy.progress_ratio > best_progress:
			best_progress = enemy.progress_ratio
			best = enemy
	
	return best


static func _get_last(enemies: Array[Enemy]) -> Enemy:
	# Last = least progress along the path
	var best: Enemy = null
	var best_progress: float = 2.0
	
	for enemy in enemies:
		if enemy.progress_ratio < best_progress:
			best_progress = enemy.progress_ratio
			best = enemy
	
	return best


static func _get_strongest(enemies: Array[Enemy]) -> Enemy:
	# Strongest = highest current health
	var best: Enemy = null
	var best_health: int = -1
	
	for enemy in enemies:
		if enemy.current_health > best_health:
			best_health = enemy.current_health
			best = enemy
	
	return best


static func _get_weakest(enemies: Array[Enemy]) -> Enemy:
	# Weakest = lowest current health
	var best: Enemy = null
	var best_health: int = 999999
	
	for enemy in enemies:
		if enemy.current_health < best_health:
			best_health = enemy.current_health
			best = enemy
	
	return best


static func _get_closest(enemies: Array[Enemy], tower_pos: Vector2) -> Enemy:
	# Closest = nearest to tower position
	var best: Enemy = null
	var best_dist: float = INF
	
	for enemy in enemies:
		var dist := tower_pos.distance_squared_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			best = enemy
	
	return best
