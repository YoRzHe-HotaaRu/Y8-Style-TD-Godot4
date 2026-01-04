# EventBus - Global signal hub for decoupled communication
extends Node

# Enemy signals
signal enemy_spawned(enemy: Node2D)
signal enemy_killed(enemy: Node2D, reward: int)
signal enemy_reached_end(enemy: Node2D)

# Tower signals
signal tower_placed(tower: Node2D, position: Vector2)
signal tower_sold(tower: Node2D, refund: int)

# Wave signals
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()

# Game state signals
signal game_over(victory: bool)
signal currency_changed(new_amount: int)
signal lives_changed(new_amount: int)

# UI signals
signal tower_selected_for_placement(tower_data: Resource)
signal placement_cancelled()
