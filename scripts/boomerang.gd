class_name Boomerang
extends Node2D

# Emitted when the player successfully catches the boomerang via CATCH ability.
signal caught

# Emitted when the boomerang is back in the player's hand
# (whether caught or auto-returned). Not emitted for clones.
signal returned

const HELD := 0
const FLYING := 1
const LAP_END_GRACE := 0.06   # seconds boomerang hovers at player before snap

@export_group("Setup")
@export var stats: BoomerangStats
@export var player: Node2D
@export var held_offset: Vector2 = Vector2(20, 0)

@export_group("Spin")
@export var held_spin_speed: float = 2.0
@export var flight_spin_speed: float = 6.0

@export_group("Combat")
@export var base_damage: float = 10.0

# ── Flags ─────────────────────────────────────────────────────────────────
# Set by the ability that spawns this instance. Clones never return to HELD;
# they are freed at end of their lap.
var is_clone: bool = false

# ── Modifiers ─────────────────────────────────────────────────────────────
# Set by abilities DURING flight (e.g. BLEED, KNOCKBACK, FREEZE, GROW).
# Cleared on launch and again on return.
var damage_multiplier: float = 1.0
var knockback_force: float = 0.0
var slow_factor: float = 0.0
var slow_duration: float = 0.0
var freeze_duration: float = 0.0
var visual_scale: float = 1.0

# ── Flight internals (also read by MultipleBoomerangsAbility) ─────────────
var _state: int = HELD
var _origin: Vector2
var _aim: Vector2 = Vector2.UP
var _range: float = 100.0
var _curve: float = 30.0
var _lap_beats: float = 3.5
var _throw_beat: float = 0.0
var _already_hit: Array = []

@onready var hitbox: Area2D = get_node_or_null("Hitbox")

# ── Lifecycle ─────────────────────────────────────────────────────────────

func _ready() -> void:
	if hitbox:
		hitbox.area_entered.connect(_on_hit_area)

func is_held() -> bool: return _state == HELD
func is_flying() -> bool: return _state == FLYING

# ── Launch ────────────────────────────────────────────────────────────────

func launch(from: Vector2, aim: Vector2, range_px: float, curve_px: float,
			lap_beats: float) -> bool:
	if _state != HELD:
		return false
	_origin = from
	_aim = aim.normalized() if aim.length_squared() > 0.001 else Vector2.UP
	_range = range_px
	_curve = curve_px
	_lap_beats = maxf(lap_beats, 0.5)
	_throw_beat = Conductor.beat()
	_state = FLYING
	global_position = _origin
	_already_hit.clear()
	_clear_modifiers()
	return true

# ── Catch ─────────────────────────────────────────────────────────────────

func try_catch() -> bool:
	if _state != FLYING:
		return false
	if global_position.distance_to(player.global_position) > stats.catch_radius:
		return false
	_reset_to_held()
	caught.emit()
	return true

# ── Per-frame ─────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if _state == HELD:
		global_position = player.global_position + held_offset
		rotation += TAU * held_spin_speed * delta
		return

	# FLYING
	rotation -= TAU * flight_spin_speed * delta
	scale = scale.lerp(Vector2.ONE * visual_scale, 0.25)
	_update_position()

func _update_position() -> void:
	var elapsed := Conductor.beat() - _throw_beat
	if elapsed < 0.0:
		elapsed = 0.0

	# Lap complete + grace → auto-return. No looping.
	if elapsed >= _lap_beats + LAP_END_GRACE:
		_reset_to_held()
		return

	# Hover at player during the grace window by clamping t to 1.0
	var lap_t := clampf(elapsed / _lap_beats, 0.0, 1.0)
	global_position = BoomerangPath.evaluate(
		lap_t, _origin, _aim, _range, _curve, player.global_position
	)

# ── State transitions ─────────────────────────────────────────────────────

func _reset_to_held() -> void:
	if is_clone:
		set_process(false)
		queue_free()
		return
	_state = HELD
	global_position = player.global_position + held_offset
	_clear_modifiers()
	returned.emit()

func _clear_modifiers() -> void:
	damage_multiplier = 1.0
	knockback_force = 0.0
	slow_factor = 0.0
	slow_duration = 0.0
	freeze_duration = 0.0
	visual_scale = 1.0
	scale = Vector2.ONE

	# TrailSpawners are added as children of this boomerang
	for child in get_children():
		if child.name.begins_with("TrailSpawner"):
			child.queue_free()

# ── Combat ────────────────────────────────────────────────────────────────

func _on_hit_area(area: Area2D) -> void:
	# Enemy hitbox is a child Area2D of an Enemy node. Accept either.
	var enemy: Node = area
	if not enemy.has_method("take_damage"):
		enemy = area.get_parent()
	if enemy == null or not enemy.has_method("take_damage"):
		return

	if enemy in _already_hit:
		return
	_already_hit.append(enemy)

	enemy.take_damage(base_damage * damage_multiplier)

	if knockback_force > 0.0 and enemy.has_method("apply_knockback"):
		var dir := (enemy.global_position - global_position).normalized()
		enemy.apply_knockback(dir * knockback_force)

	if slow_factor > 0.0 and enemy.has_method("apply_slow"):
		enemy.apply_slow(slow_factor, slow_duration)

	if freeze_duration > 0.0 and enemy.has_method("apply_freeze"):
		enemy.apply_freeze(freeze_duration)
