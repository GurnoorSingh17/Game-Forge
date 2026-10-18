extends Node2D

@export var radius: float = 22.0
@export var ring_color: Color = Color(1, 1, 1, 0.75)
@export var ring_width: float = 3.0
@export var pulse_speed: float = 3.0

var _t: float = 0.0

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	var pulse := sin(_t * pulse_speed) * 0.15 + 1.0
	draw_arc(Vector2.ZERO, radius * pulse, 0, TAU, 32, ring_color, ring_width)
	draw_circle(Vector2.ZERO, 4.0, ring_color)
