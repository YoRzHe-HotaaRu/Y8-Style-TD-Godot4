# TowerData - Resource defining tower properties
class_name TowerData
extends Resource

@export var display_name: String = "Tower"
@export var cost: int = 50
@export var damage: int = 20
@export var attack_speed: float = 1.0  # Attacks per second
@export var range_radius: float = 150.0
@export var projectile_speed: float = 400.0
@export var color: Color = Color.BLUE
@export var size: float = 24.0
@export_enum("First", "Last", "Strongest", "Weakest", "Closest") var targeting_mode: int = 0
@export_enum("Square", "Diamond", "Octagon") var shape: int = 0
@export var splash_radius: float = 0.0  # 0 = single target
