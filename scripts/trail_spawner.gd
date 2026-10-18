extends Node2D

@export var spawn_interval: float = 0.07
@export var zone_scene: PackedScene
@export var color: Color = Color(1, 0.4, 0.1, 0.7)
@export var damage_per_second: float = 8.0
@export var slow_factor: float = 0.0
@export var freeze_duration: float = 0.0

var _timer: float = 0.0

func _process(delta: float) -> void:
	if not is_instance_valid(get_parent()):
		return
	_timer += delta
	if _timer >= spawn_interval:
		_timer = 0.0
		_spawn()

func _spawn() -> void:
	if zone_scene == null: return
	var host := get_parent()
	if host == null: return
	var z := zone_scene.instantiate()
	z.global_position = host.global_position
	z.color = color
	z.damage_per_second = damage_per_second
	z.slow_factor = slow_factor
	z.freeze_duration = freeze_duration
	host.get_parent().add_child(z)
