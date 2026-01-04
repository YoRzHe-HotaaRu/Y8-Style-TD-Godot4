# PlacementSystem - Handles tower placement logic
class_name PlacementSystem
extends Node2D

signal tower_placed(tower: Tower, position: Vector2)
signal placement_cancelled()

# Configuration
@export var tower_container: Node2D
@export var placement_area: Rect2 = Rect2(0, 0, 1280, 720)

# State
var is_placing: bool = false
var selected_tower_data: TowerData
var preview_tower: Node2D
var can_place_here: bool = false

# Placement grid
var grid_size: int = 32
var occupied_cells: Dictionary = {}

# Path exclusion
var path_points: PackedVector2Array = []
var path_width: float = 40.0

# Preloaded
var tower_scene: PackedScene


func _ready() -> void:
	tower_scene = preload("res://scenes/towers/tower.tscn")
	
	# Connect to EventBus
	EventBus.tower_selected_for_placement.connect(_on_tower_selected)
	EventBus.placement_cancelled.connect(_on_placement_cancelled)


func _process(_delta: float) -> void:
	if is_placing and preview_tower:
		var mouse_pos := get_global_mouse_position()
		var snapped_pos := _snap_to_grid(mouse_pos)
		preview_tower.global_position = snapped_pos
		
		can_place_here = _is_valid_placement(snapped_pos)
		_update_preview_color()


func _input(event: InputEvent) -> void:
	if not is_placing:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			# Check if clicking on UI
			var mouse_pos := get_global_mouse_position()
			if mouse_pos.x > 170:  # Not clicking on tower panel
				print("Placement: Left click at ", mouse_pos)
				_try_place_tower()
				get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			print("Placement: Right click - cancelling")
			_cancel_placement()
			get_viewport().set_input_as_handled()


func set_path_exclusion(path: Path2D, width: float = 40.0) -> void:
	path_width = width
	if path and path.curve:
		path_points = path.curve.get_baked_points()
		# Transform to global coordinates
		for i in range(path_points.size()):
			path_points[i] = path.to_global(path_points[i])


func start_placement(tower_data: TowerData) -> void:
	print("Placement: start_placement called for ", tower_data.display_name if tower_data else "NULL")
	if is_placing:
		_cancel_placement()
	
	selected_tower_data = tower_data
	
	# Check if can afford
	if not GameManager.can_afford(tower_data.cost):
		print("Placement: Cannot afford - cost=", tower_data.cost, " currency=", GameManager.currency)
		return
	
	is_placing = true
	print("Placement: Now in placement mode")
	
	# Create preview
	preview_tower = Node2D.new()
	var preview_sprite := Sprite2D.new()
	preview_tower.add_child(preview_sprite)
	add_child(preview_tower)
	
	# Generate preview texture
	_generate_preview_sprite(preview_sprite, tower_data)
	
	# Draw range circle
	var range_visual := Node2D.new()
	range_visual.set_script(preload("res://scripts/systems/range_drawer.gd"))
	range_visual.set("radius", tower_data.range_radius)
	preview_tower.add_child(range_visual)
	print("Placement: Preview created")


func _try_place_tower() -> void:
	print("Placement: Trying to place tower, can_place=", can_place_here, " data=", selected_tower_data)
	if not can_place_here or not selected_tower_data:
		print("Placement: Cannot place - invalid location or no tower selected")
		return
	
	if not GameManager.spend_currency(selected_tower_data.cost):
		print("Placement: Cannot afford tower")
		SoundManager.play_cannot_afford()
		return
	
	var pos := preview_tower.global_position
	print("Placement: Placing tower at ", pos)
	
	# Play placement sound
	SoundManager.play_tower_place()
	
	# Instantiate tower
	var tower: Tower = tower_scene.instantiate()
	
	if tower_container:
		tower_container.add_child(tower)
		print("Placement: Tower added to container")
	else:
		get_parent().add_child(tower)
		print("Placement: Tower added to parent")
	
	tower.global_position = pos
	tower.initialize(selected_tower_data)
	print("Placement: Tower initialized with ", selected_tower_data.display_name)
	
	# Mark cell as occupied
	var cell := _pos_to_cell(pos)
	occupied_cells[cell] = true
	
	tower_placed.emit(tower, pos)
	EventBus.tower_placed.emit(tower, pos)
	
	_cancel_placement()


func _cancel_placement() -> void:
	is_placing = false
	selected_tower_data = null
	
	if preview_tower:
		preview_tower.queue_free()
		preview_tower = null
	
	placement_cancelled.emit()


func _is_valid_placement(pos: Vector2) -> bool:
	# Check bounds
	if not placement_area.has_point(pos):
		return false
	
	# Check if cell is occupied
	var cell := _pos_to_cell(pos)
	if occupied_cells.has(cell):
		return false
	
	# Check if on path
	if _is_on_path(pos):
		return false
	
	return true


func _is_on_path(pos: Vector2) -> bool:
	for point in path_points:
		if pos.distance_to(point) < path_width:
			return true
	return false


func _snap_to_grid(pos: Vector2) -> Vector2:
	return Vector2(
		snapped(pos.x, grid_size) + grid_size / 2,
		snapped(pos.y, grid_size) + grid_size / 2
	)


func _pos_to_cell(pos: Vector2) -> Vector2i:
	return Vector2i(int(pos.x / grid_size), int(pos.y / grid_size))


func _update_preview_color() -> void:
	if not preview_tower:
		return
	
	var sprite := preview_tower.get_child(0) as Sprite2D
	if sprite:
		if can_place_here:
			sprite.modulate = Color(0.5, 1.0, 0.5, 0.7)  # Green
		else:
			sprite.modulate = Color(1.0, 0.3, 0.3, 0.7)  # Red


# SVG texture paths for preview
const BASE_PREVIEW_TEXTURES := {
	0: "res://assets/towers/tower_basic_base.svg",
	1: "res://assets/towers/tower_sniper_base.svg",
	2: "res://assets/towers/tower_splash_base.svg"
}


func _generate_preview_sprite(sprite: Sprite2D, data: TowerData) -> void:
	# Load SVG texture for preview
	if BASE_PREVIEW_TEXTURES.has(data.shape):
		var tex := load(BASE_PREVIEW_TEXTURES[data.shape])
		if tex:
			sprite.texture = tex
			sprite.scale = Vector2(0.75, 0.75)  # Match tower scale


func _on_tower_selected(tower_data: TowerData) -> void:
	print("Placement: Received tower selection - ", tower_data.display_name)
	start_placement(tower_data)


func _on_placement_cancelled() -> void:
	if is_placing:
		_cancel_placement()
