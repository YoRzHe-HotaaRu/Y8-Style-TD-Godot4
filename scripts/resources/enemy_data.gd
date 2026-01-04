# EnemyData - Resource defining enemy properties
class_name EnemyData
extends Resource

@export var display_name: String = "Enemy"
@export var max_health: int = 100
@export var speed: float = 100.0
@export var reward: int = 10
@export var damage_to_base: int = 1
@export var color: Color = Color.RED
@export var size: float = 16.0
@export_enum("Circle", "Triangle", "Hexagon") var shape: int = 0
