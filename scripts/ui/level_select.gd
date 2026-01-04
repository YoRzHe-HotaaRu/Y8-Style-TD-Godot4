# LevelSelect - Level selection menu
extends Control

@onready var grid_container: GridContainer = $CenterContainer/VBoxContainer/GridContainer
@onready var back_button: Button = $CenterContainer/VBoxContainer/BackButton

# Level data
const TOTAL_LEVELS := 10


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	_create_level_buttons()


func _create_level_buttons() -> void:
	for i in range(TOTAL_LEVELS):
		var level_num: int = i + 1
		var button := _create_level_button(level_num)
		grid_container.add_child(button)


func _create_level_button(level_num: int) -> Control:
	# Create card container
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(150, 120)
	
	# Style based on difficulty
	var style := StyleBoxFlat.new()
	var difficulty_color := _get_difficulty_color(level_num)
	style.bg_color = Color(difficulty_color.r * 0.3, difficulty_color.g * 0.3, difficulty_color.b * 0.3, 0.95)
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = difficulty_color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	card.add_theme_stylebox_override("panel", style)
	
	# VBox for content
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 8)
	card.add_child(vbox)
	
	# Level number
	var level_label := Label.new()
	level_label.text = "Level %d" % level_num
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size", 24)
	level_label.add_theme_color_override("font_color", difficulty_color)
	vbox.add_child(level_label)
	
	# Difficulty stars
	var stars_label := Label.new()
	var star_count: int = _get_star_rating(level_num)
	stars_label.text = "⭐".repeat(star_count)
	stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars_label.add_theme_font_size_override("font_size", 16)
	vbox.add_child(stars_label)
	
	# Waves info
	var waves_label := Label.new()
	waves_label.text = "%d Waves" % _get_wave_count(level_num)
	waves_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	waves_label.add_theme_font_size_override("font_size", 14)
	waves_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(waves_label)
	
	# Clickable button overlay
	var button := Button.new()
	button.flat = true
	button.anchors_preset = Control.PRESET_FULL_RECT
	button.pressed.connect(_on_level_selected.bind(level_num))
	button.mouse_entered.connect(_on_card_hover.bind(card, style, true))
	button.mouse_exited.connect(_on_card_hover.bind(card, style, false))
	card.add_child(button)
	
	return card


func _get_difficulty_color(level: int) -> Color:
	# Green -> Yellow -> Orange -> Red based on difficulty
	var t: float = float(level - 1) / float(TOTAL_LEVELS - 1)
	if t < 0.33:
		return Color(0.3, 0.8, 0.3)  # Easy - Green
	elif t < 0.66:
		return Color(0.9, 0.7, 0.2)  # Medium - Yellow
	else:
		return Color(0.9, 0.3, 0.2)  # Hard - Red


func _get_star_rating(level: int) -> int:
	if level <= 3:
		return 1
	elif level <= 6:
		return 2
	elif level <= 8:
		return 3
	elif level <= 9:
		return 4
	else:
		return 5


func _get_wave_count(level: int) -> int:
	# More waves as levels increase
	return 3 + level


func _on_card_hover(card: Control, style: StyleBoxFlat, hovering: bool) -> void:
	if hovering:
		style.bg_color.a = 1.0
		card.scale = Vector2(1.05, 1.05)
		SoundManager.play_button_hover()
	else:
		style.bg_color.a = 0.95
		card.scale = Vector2(1.0, 1.0)


func _on_level_selected(level_num: int) -> void:
	SoundManager.play_button_click()
	# Store selected level in GameManager
	GameManager.selected_level = level_num
	# Go to game
	get_tree().change_scene_to_file("res://scenes/main/level.tscn")


func _on_back_pressed() -> void:
	SoundManager.play_button_click()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")
