extends Area2D

@export var lifetime: float = 2.0
@export var radius: float = 20.0
@export var color: Color = Color(1, 0.4, 0.1, 0.7)
@export var damage_per_second: float = 8.0
@export var slow_factor: float = 0.0
@export var freeze_duration: float = 0.0

var _t: float = 0.0
var _inside: Array = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, lifetime)
	queue_redraw()

func _process(delta: float) -> void:
	_t += delta
	if _t >= lifetime:
		queue_free()
		return

	for e in _inside:
		if not is_instance_valid(e): continue
		if damage_per_second > 0.0:
			e.take_damage(damage_per_second * delta)
		if slow_factor > 0.0 and e.has_method("apply_slow"):
			e.apply_slow(slow_factor, 0.2)
		if freeze_duration > 0.0 and e.has_method("apply_freeze"):
			e.apply_freeze(0.2)

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, color)

func _on_area_entered(area: Area2D) -> void:
	var e := area.get_parent()
	if e != null and e.has_method("take_damage") and e not in _inside:
		_inside.append(e)

func _on_area_exited(area: Area2D) -> void:
	var e := area.get_parent()
	if e != null:
		_inside.erase(e)
