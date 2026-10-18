class_name Enemy
extends CharacterBody2D

signal died

@export_group("Stats")
@export var max_health: float = 60.0
@export var move_speed: float = 80.0
@export var contact_damage: float = 10.0
@export var knockback_resistance: float = 0.0

@onready var contact_area: Area2D = get_node_or_null("ContactArea")

var health: float
var target: Node2D

var _slow_until: float = 0.0
var _freeze_until: float = 0.0

func _ready() -> void:
	health = max_health
	if not is_in_group("enemies"):
		add_to_group("enemies")
	target = get_tree().get_first_node_in_group("player")
	if contact_area:
		contact_area.body_entered.connect(_on_contact_body_entered)

func _physics_process(delta: float) -> void:
	if _is_frozen():
		velocity = Vector2.ZERO
		modulate = Color(0.5, 0.8, 1.0, 0.8)
		move_and_slide()
		return

	if _is_slowed():
		modulate = modulate.lerp(Color(0.6, 0.7, 1.0), delta * 6.0)
	else:
		modulate = modulate.lerp(Color.WHITE, delta * 6.0)

	var speed_mod := 0.4 if _is_slowed() else 1.0
	_move(delta, move_speed * speed_mod)

func _move(_delta: float, speed: float) -> void:
	if speed <= 0.001 or target == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	var dir := (target.global_position - global_position).normalized()
	velocity = dir * speed
	move_and_slide()

func _is_frozen() -> bool:
	return Time.get_ticks_msec() * 0.001 < _freeze_until

func _is_slowed() -> bool:
	return Time.get_ticks_msec() * 0.001 < _slow_until

func take_damage(amount: float) -> void:
	health -= amount
	_flash_hurt()
	if health <= 0.0:
		_die()

func apply_knockback(force: Vector2) -> void:
	var applied := force * (1.0 - clampf(knockback_resistance, 0.0, 1.0))
	if applied.length_squared() < 0.01:
		return
	var start := global_position
	global_position += applied * 0.15
	create_tween().tween_property(self, "global_position", start, 0.12)

func apply_slow(_factor: float, duration: float) -> void:
	var until := Time.get_ticks_msec() * 0.001 + duration
	_slow_until = maxf(_slow_until, until)

func apply_freeze(duration: float) -> void:
	var until := Time.get_ticks_msec() * 0.001 + duration
	_freeze_until = maxf(_freeze_until, until)

func _flash_hurt() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 0.4, 0.4), 0.05)
	t.tween_property(self, "modulate", Color.WHITE, 0.15)

func _on_contact_body_entered(body: Node) -> void:
	if body == null or not body.is_in_group("player"):
		return
	if body.has_method("take_damage"):
		body.take_damage(contact_damage)

func _die() -> void:
	died.emit()
	queue_free()
