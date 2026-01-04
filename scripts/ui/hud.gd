# HUD - In-game heads-up display with Minecraft-style hotbar
extends CanvasLayer

# References
@onready var currency_label: Label = $TopBar/CurrencyLabel
@onready var lives_label: Label = $TopBar/LivesLabel
@onready var wave_label: Label = $TopBar/WaveLabel
@onready var start_wave_button: Button = $TopBar/StartWaveButton
@onready var tower_hotbar: PanelContainer = $TowerHotbar
@onready var game_over_panel: Panel = $GameOverPanel
@onready var game_over_label: Label = $GameOverPanel/VBoxContainer/ResultLabel
@onready var restart_button: Button = $GameOverPanel/VBoxContainer/RestartButton
@onready var main_menu_button: Button = $GameOverPanel/VBoxContainer/MainMenuButton

# Tower card references
var tower_cards: Array[Control] = []

# Tower data
var tower_data_basic: TowerData
var tower_data_sniper: TowerData
var tower_data_splash: TowerData

# Tower textures for cards
const TOWER_TEXTURES := {
	0: "res://assets/towers/tower_basic_base.svg",
	1: "res://assets/towers/tower_sniper_base.svg",
	2: "res://assets/towers/tower_splash_base.svg"
}


func _ready() -> void:
	# Load tower data
	tower_data_basic = preload("res://resources/towers/tower_basic.tres")
	tower_data_sniper = preload("res://resources/towers/tower_sniper.tres")
	tower_data_splash = preload("res://resources/towers/tower_splash.tres")
	
	# Connect to EventBus
	EventBus.currency_changed.connect(_on_currency_changed)
	EventBus.lives_changed.connect(_on_lives_changed)
	EventBus.wave_started.connect(_on_wave_started)
	EventBus.wave_completed.connect(_on_wave_completed)
	EventBus.game_over.connect(_on_game_over)
	
	# Setup buttons
	_setup_tower_cards()
	start_wave_button.pressed.connect(_on_start_wave_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Initial update
	_update_display()
	game_over_panel.visible = false


func _setup_tower_cards() -> void:
	# Get the HBox container inside the hotbar
	var hbox := tower_hotbar.get_node_or_null("HBox")
	if not hbox:
		hbox = tower_hotbar
	
	# Clear existing cards
	for child in hbox.get_children():
		child.queue_free()
	tower_cards.clear()
	
	# Create tower cards with images
	var towers := [tower_data_basic, tower_data_sniper, tower_data_splash]
	for i in range(towers.size()):
		var tower_data: TowerData = towers[i]
		var card := _create_tower_card(tower_data, i)
		hbox.add_child(card)
		tower_cards.append(card)


func _create_tower_card(tower_data: TowerData, index: int) -> Control:
	# Create card container
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(110, 75)
	
	# Style the card
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.4, 0.4, 0.5, 0.8)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	card.add_theme_stylebox_override("panel", style)
	
	# VBox for layout
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 4)
	card.add_child(vbox)
	
	# Tower image
	var texture_rect := TextureRect.new()
	texture_rect.custom_minimum_size = Vector2(40, 40)
	texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if TOWER_TEXTURES.has(tower_data.shape):
		texture_rect.texture = load(TOWER_TEXTURES[tower_data.shape])
	vbox.add_child(texture_rect)
	
	# Cost label
	var cost_label := Label.new()
	cost_label.text = "$%d" % tower_data.cost
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cost_label.add_theme_font_size_override("font_size", 14)
	cost_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.3))
	vbox.add_child(cost_label)
	
	# Make it clickable with a button overlay
	var button := Button.new()
	button.flat = true
	button.anchors_preset = Control.PRESET_FULL_RECT
	button.pressed.connect(_on_tower_card_pressed.bind(tower_data, card))
	button.mouse_entered.connect(_on_tower_card_hover.bind(card, true))
	button.mouse_exited.connect(_on_tower_card_hover.bind(card, false))
	card.add_child(button)
	
	# Store reference
	card.set_meta("tower_data", tower_data)
	card.set_meta("button", button)
	card.set_meta("style", style)
	
	return card


func _on_tower_card_pressed(tower_data: TowerData, card: Control) -> void:
	print("HUD: Tower card pressed - ", tower_data.display_name)
	SoundManager.play_button_click()
	EventBus.tower_selected_for_placement.emit(tower_data)


func _on_tower_card_hover(card: Control, hovering: bool) -> void:
	var style: StyleBoxFlat = card.get_meta("style")
	if hovering:
		style.border_color = Color(0.6, 0.7, 0.9, 1.0)
		style.bg_color = Color(0.2, 0.2, 0.3, 0.95)
		SoundManager.play_button_hover()
	else:
		style.border_color = Color(0.4, 0.4, 0.5, 0.8)
		style.bg_color = Color(0.15, 0.15, 0.2, 0.9)


func _update_display() -> void:
	_on_currency_changed(GameManager.currency)
	_on_lives_changed(GameManager.lives)


func _on_currency_changed(amount: int) -> void:
	if currency_label:
		currency_label.text = "💰 %d" % amount
	
	# Update card affordability
	_update_card_states()


func _on_lives_changed(amount: int) -> void:
	if lives_label:
		lives_label.text = "❤️ %d" % amount


func _on_wave_started(wave_number: int) -> void:
	if wave_label:
		wave_label.text = "Wave: %d" % wave_number
	start_wave_button.disabled = true


func _on_wave_completed(_wave_number: int) -> void:
	start_wave_button.disabled = false


func _on_game_over(victory: bool) -> void:
	game_over_panel.visible = true
	if victory:
		game_over_label.text = "VICTORY!"
		game_over_label.add_theme_color_override("font_color", Color(0.2, 0.8, 0.2))
	else:
		game_over_label.text = "GAME OVER"
		game_over_label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.2))


func _on_start_wave_pressed() -> void:
	print("HUD: Start Wave button pressed!")
	SoundManager.play_button_click()
	var wave_manager := get_tree().get_first_node_in_group("wave_manager")
	if wave_manager:
		print("HUD: Found wave_manager, calling start_next_wave()")
		wave_manager.start_next_wave()
	else:
		print("HUD: ERROR - wave_manager not found!")


func _on_restart_pressed() -> void:
	SoundManager.play_button_click()
	GameManager.reset_game()
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	SoundManager.play_button_click()
	GameManager.reset_game()
	get_tree().change_scene_to_file("res://scenes/ui/main_menu.tscn")


func _update_card_states() -> void:
	var towers := [tower_data_basic, tower_data_sniper, tower_data_splash]
	for i in range(tower_cards.size()):
		if i < towers.size():
			var card: Control = tower_cards[i]
			var button: Button = card.get_meta("button")
			var style: StyleBoxFlat = card.get_meta("style")
			var can_afford: bool = GameManager.can_afford(towers[i].cost)
			
			button.disabled = not can_afford
			if can_afford:
				card.modulate = Color(1, 1, 1, 1)
			else:
				card.modulate = Color(0.5, 0.5, 0.5, 0.7)
