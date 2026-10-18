class_name BoomerangPreview
extends Node2D

@export var spacing: float = 22.0
@export var max_dots: int = 64
@export var dot_radius: float = 5.0
@export var dot_color: Color = Color.WHITE
@export var end_alpha: float = 0.35
@export var pulse_speed: float = 6.0
@export var pulse_wavelength: float = 0.45

var _pts := PackedVector2Array()
var _time: float = 0.0
var _active: bool = false

func _process(delta: float) -> void:
	_time += delta
	if _active:
		queue_redraw()

func show_path(origin: Vector2, aim: Vector2, range_px: float, sweep_px: float, target: Vector2) -> void:
	BoomerangPath.sample_even_spacing(
		_pts, origin, aim, range_px, sweep_px, target, spacing, max_dots
	)
	_active = true
	queue_redraw()
func hide_path() -> void:
	_active = false
	_pts.clear()
	queue_redraw()

func _draw() -> void:
	if not _active or _pts.size() == 0:
		return
	var n := _pts.size()
	for i in n:
		var f := float(i) / float(max(n - 1, 1))
		var r := lerpf(dot_radius, dot_radius * 0.3, f)
		var pulse := sin(_time * pulse_speed - i * pulse_wavelength) * 0.15 + 0.85
		var c := dot_color
		c.a = lerpf(1.0, end_alpha, f) * pulse
		draw_circle(to_local(_pts[i]), r, c)
