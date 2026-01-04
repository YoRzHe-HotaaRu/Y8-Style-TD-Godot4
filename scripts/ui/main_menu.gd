# MainMenu - Title screen with game options
extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var play_button: Button = $VBoxContainer/ButtonContainer/PlayButton
@onready var quit_button: Button = $VBoxContainer/ButtonContainer/QuitButton
@onready var version_label: Label = $VersionLabel

# Floating enemies for background animation
var floating_enemies: Array[Node2D] = []
var enemy_textures: Array[Texture2D] = []


func _ready() -> void:
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	play_button.mouse_entered.connect(_on_button_hover)
	quit_button.mouse_entered.connect(_on_button_hover)
	
	# Load enemy textures for background
	enemy_textures = [
		load("res://assets/enemies/enemy_basic.svg"),
		load("res://assets/enemies/enemy_fast.svg"),
		load("res://assets/enemies/enemy_tank.svg")
	]
	
	# Create floating enemies
	_create_floating_enemies()
	
	# Animate title
	_animate_title()


func _process(delta: float) -> void:
	# Animate floating enemies
	for enemy in floating_enemies:
		if not is_instance_valid(enemy):
			continue
		enemy.position.x += enemy.get_meta("speed") * delta
		enemy.position.y += sin(Time.get_ticks_msec() * 0.001 + enemy.get_meta("phase")) * 0.5
		
		# Wrap around screen
		if enemy.position.x > get_viewport_rect().size.x + 50:
			enemy.position.x = -50
			enemy.position.y = randf_range(100, get_viewport_rect().size.y - 100)


func _create_floating_enemies() -> void:
	var bg_container := $BackgroundEnemies
	
	for i in range(8):
		var sprite := Sprite2D.new()
		sprite.texture = enemy_textures[i % enemy_textures.size()]
		sprite.scale = Vector2(0.6, 0.6)
		sprite.modulate = Color(1, 1, 1, 0.3)  # Semi-transparent
		sprite.position = Vector2(
			randf_range(-50, get_viewport_rect().size.x),
			randf_range(100, get_viewport_rect().size.y - 100)
		)
		sprite.set_meta("speed", randf_range(20, 60))
		sprite.set_meta("phase", randf() * TAU)
		bg_container.add_child(sprite)
		floating_enemies.append(sprite)


func _animate_title() -> void:
	if title_label:
		var tween := create_tween().set_loops()
		tween.tween_property(title_label, "modulate", Color(1.2, 1.0, 0.8, 1), 1.5)
		tween.tween_property(title_label, "modulate", Color(1.0, 0.8, 0.6, 1), 1.5)


func _on_button_hover() -> void:
	SoundManager.play_button_hover()


func _on_play_pressed() -> void:
	SoundManager.play_button_click()
	# Go to level selection
	get_tree().change_scene_to_file("res://scenes/ui/level_select.tscn")


func _on_quit_pressed() -> void:
	SoundManager.play_button_click()
	get_tree().quit()
