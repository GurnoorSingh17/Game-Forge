class_name PlayerThrow
extends Node2D

@export var boomerang: Boomerang
@export var preview: BoomerangPreview
@export var marker: Node2D
@export var stats: BoomerangStats

var _aiming: bool = false
var _aim: Vector2 = Vector2.UP
var _range: float = 100.0
var _curve: float = 30.0
var _valid: bool = false

func _process(_delta: float) -> void:
	# Marker follows the player while the boomerang is held/returned.
	# While flying, it stays frozen at the launch point.
	if marker and boomerang.is_held():
		marker.position = global_position

	if _aiming:
		# Slingshot: aim direction is OPPOSITE the pull.
		var pull := global_position - get_global_mouse_position()
		var pull_dist := pull.length()
		_valid = pull_dist >= stats.min_pull

		if pull_dist > 0.001:
			_aim = pull / pull_dist
		var t := clampf(inverse_lerp(stats.min_pull, stats.max_pull, pull_dist), 0.0, 1.0)
		_range = lerpf(stats.min_range, stats.max_range, t)
		_curve = _range * stats.curve_ratio

		var origin := marker.position if marker else global_position
		preview.show_path(origin, _aim, _range, _curve)
		preview.dot_color = Color.WHITE if _valid else Color(1, 0.35, 0.35, 0.7)

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton): return
	if event.button_index != MOUSE_BUTTON_LEFT: return
	if not boomerang.is_held(): return    # ← was: if boomerang.is_in_flight(): return

	if event.pressed:
		_aiming = true
	elif _aiming:
		_aiming = false
		preview.hide_path()
		if _valid:
			var origin := marker.position if marker else global_position
			boomerang.launch(origin, _aim, _range, _curve)
