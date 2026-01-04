# RangeDrawer - Draws a circle to show tower range
extends Node2D

var radius: float = 150.0
var color: Color = Color(0.3, 0.6, 1.0, 0.2)
var border_color: Color = Color(0.3, 0.6, 1.0, 0.5)


func _draw() -> void:
	# Filled circle
	draw_circle(Vector2.ZERO, radius, color)
	
	# Border
	draw_arc(Vector2.ZERO, radius, 0, TAU, 64, border_color, 2.0)
