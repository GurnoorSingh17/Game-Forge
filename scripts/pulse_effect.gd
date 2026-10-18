extends Node2D

@export var lifetime: float = 0.4
@export var radius_max: float = 90.0
@export var color: Color = Color(0.3, 0.9, 1.0, 1.0)
@export var line_width: float = 4.0

var _t := 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()
	if _t >= lifetime:
		queue_free()

func _draw() -> void:
	var p := clampf(_t / lifetime, 0.0, 1.0)
	var r := radius_max * p
	var ring := color
	ring.a = 1.0 - p
	draw_arc(Vector2.ZERO, r, 0.0, TAU, 48, ring, line_width, true)
	var fill := color
	fill.a = (1.0 - p) * 0.35
	draw_circle(Vector2.ZERO, r * 0.7, fill)
