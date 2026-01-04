# SoundManager - Handles all game audio with real audio files
extends Node

# Audio players for different sound types
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer

# Sound settings
var sfx_volume: float = 0.5
var music_volume: float = 0.3
var sfx_enabled: bool = true
var music_enabled: bool = true

# Pool size for concurrent sounds
const SFX_POOL_SIZE = 8

# Preloaded sounds
var sound_click: AudioStream
var sound_hover: AudioStream
var sound_place: AudioStream
var sound_shoot: AudioStream
var sound_hit: AudioStream
var sound_coin: AudioStream
var sound_wave_start: AudioStream
var sound_victory: AudioStream
var sound_game_over: AudioStream


func _ready() -> void:
	# Create SFX player pool
	for i in range(SFX_POOL_SIZE):
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_players.append(player)
	
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Master"
	add_child(music_player)
	
	# Load audio files
	_load_sounds()


func _load_sounds() -> void:
	sound_click = _load_audio("res://assets/audio/click.wav")
	sound_hover = _load_audio("res://assets/audio/hover.wav")
	sound_place = _load_audio("res://assets/audio/place.wav")
	sound_shoot = _load_audio("res://assets/audio/shoot.wav")
	sound_hit = _load_audio("res://assets/audio/hit.wav")
	sound_coin = _load_audio("res://assets/audio/coin.wav")
	sound_wave_start = _load_audio("res://assets/audio/wave_start.wav")
	sound_victory = _load_audio("res://assets/audio/victory.wav")
	sound_game_over = _load_audio("res://assets/audio/game_over.wav")


func _load_audio(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		return load(path)
	else:
		push_warning("SoundManager: Audio file not found: " + path)
		return null


func _get_free_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	# If all busy, return first one (will interrupt)
	return sfx_players[0]


func _play_sound(stream: AudioStream, volume_multiplier: float = 1.0) -> void:
	if not sfx_enabled or stream == null:
		return
	var player := _get_free_player()
	player.stream = stream
	player.volume_db = linear_to_db(sfx_volume * volume_multiplier)
	player.play()


# ===== PLAY SOUND FUNCTIONS =====

func play_button_click() -> void:
	_play_sound(sound_click, 0.8)


func play_button_hover() -> void:
	_play_sound(sound_hover, 0.5)


func play_tower_place() -> void:
	_play_sound(sound_place, 1.0)


func play_tower_shoot() -> void:
	_play_sound(sound_shoot, 0.6)


func play_enemy_hit() -> void:
	_play_sound(sound_hit, 0.4)


func play_enemy_death() -> void:
	_play_sound(sound_hit, 0.7)


func play_wave_start() -> void:
	_play_sound(sound_wave_start, 0.9)


func play_wave_complete() -> void:
	_play_sound(sound_coin, 1.0)


func play_game_over() -> void:
	_play_sound(sound_game_over, 1.0)


func play_victory() -> void:
	_play_sound(sound_victory, 1.0)


func play_coin_collect() -> void:
	_play_sound(sound_coin, 0.6)


func play_life_lost() -> void:
	_play_sound(sound_hit, 0.8)


func play_cannot_afford() -> void:
	_play_sound(sound_click, 0.5)
