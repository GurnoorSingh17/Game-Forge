class_name Boomba
extends Enemy

const EXPLOSION_FX := preload("res://scenes/pulse_effect.tscn")

@export var fuse_beats: float = 4.0
@export var explosion_radius: float = 120.0
@export var explosion_damage: float = 40.0

var _landed: bool = false

func _ready() -> void:
	max_health = 40.0
	move_speed = 0.0
	contact_damage = 0.0
	knockback_resistance = 1.0
	super()

func begin_fall(from: Vector2, to: Vector2, duration: float) -> void:
	global_position = from
	modulate.a = 0.6
	var t := create_tween()
	t.tween_property(self, "global_position", to, duration)
	t.tween_callback(_on_landed)

func _on_landed() -> void:
	_landed = true
	modulate.a = 1.0

	var duration := fuse_beats * Conductor.sec_per_beat
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 0.3, 0.1), duration)
	t.tween_callback(_explode)

func _die() -> void:
	_explode()

func _explode() -> void:
	if not is_instance_valid(self):
		return
	set_physics_process(false)

	for p in get_tree().get_nodes_in_group("player"):
		if p.global_position.distance_to(global_position) <= explosion_radius:
			if p.has_method("take_damage"):
				p.take_damage(explosion_damage)

	for e in get_tree().get_nodes_in_group("enemies"):
		if e == self: continue
		if e.global_position.distance_to(global_position) <= explosion_radius:
			if e.has_method("take_damage"):
				e.take_damage(explosion_damage * 0.5)

	var fx := EXPLOSION_FX.instantiate()
	fx.position = global_position
	fx.radius_max = explosion_radius
	fx.color = Color(1, 0.4, 0.1, 1.0)
	get_parent().add_child(fx)

	died.emit()
	queue_free()
