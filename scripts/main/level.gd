# Level - Main gameplay scene
extends Node2D

@onready var enemy_path: Path2D = $EnemyPath
@onready var towers_container: Node2D = $Towers
@onready var enemies_container: Node2D = $Enemies
@onready var projectiles_container: Node2D = $Projectiles
@onready var wave_manager: WaveManager = $WaveManager
@onready var placement_system: PlacementSystem = $PlacementSystem
@onready var hud: CanvasLayer = $HUD
@onready var background: TextureRect = $Background
@onready var path_visual: Line2D = $PathVisual


func _ready() -> void:
	print("Level: _ready called")
	add_to_group("level")
	
	# Start the game
	GameManager.start_game()
	print("Level: GameManager started, state=", GameManager.current_state)
	
	# Setup wave manager
	if wave_manager:
		wave_manager.enemy_path = enemy_path
		wave_manager.enemy_container = enemies_container
		wave_manager.add_to_group("wave_manager")
		print("Level: WaveManager configured, path=", enemy_path, " container=", enemies_container)
		print("Level: WaveManager has ", wave_manager.waves.size(), " waves")
	else:
		print("Level: ERROR - WaveManager is null!")
	
	# Setup placement system
	if placement_system:
		placement_system.tower_container = towers_container
		placement_system.set_path_exclusion(enemy_path, 40.0)
		print("Level: PlacementSystem configured")
	else:
		print("Level: ERROR - PlacementSystem is null!")
	
	# Draw path visualization
	_draw_path_visual()
	print("Level: Initialization complete")


func _draw_path_visual() -> void:
	if enemy_path and enemy_path.curve:
		var points := enemy_path.curve.get_baked_points()
		
		# Draw border layer (widest, darkest)
		var path_border := get_node_or_null("PathBorder1") as Line2D
		if path_border:
			path_border.clear_points()
			for point in points:
				path_border.add_point(point)
		
		# Draw main path layer
		if path_visual:
			path_visual.clear_points()
			for point in points:
				path_visual.add_point(point)
		
		# Draw highlight layer (thinnest, lightest)
		var path_highlight := get_node_or_null("PathHighlight") as Line2D
		if path_highlight:
			path_highlight.clear_points()
			for point in points:
				path_highlight.add_point(point)
		
		print("Level: Path visual drawn with ", points.size(), " points")
