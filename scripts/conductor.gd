extends Node

@onready var music: AudioStreamPlayer = $Music

@export var bpm: float = 120.0
@export var beat_offset: float = 0.0
signal cell_ticked(cell_index: int)

var _last_cell: int = -1

func _process(_delta: float) -> void:
	if not music.playing:
		return
	var b := beat()
	if b < 0.0:
		return
	var cell := int(floor(b * 2.0)) % 8
	if cell != _last_cell:
		_last_cell = cell
		cell_ticked.emit(cell)

var sec_per_beat: float:
	get:
		return 60.0 / bpm

func start() -> void:
	music.play()

func song_time() -> float:
	if not music.playing:
		return 0.0
	return (music.get_playback_position()
		+ AudioServer.get_time_since_last_mix()
		- AudioServer.get_output_latency())

func beat() -> float:
	return song_time() / sec_per_beat - beat_offset

# Signed distance to nearest beat, -0.5 .. 0.5
func beat_error() -> float:
	var b := beat()
	return b - round(b)
