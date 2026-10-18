extends CharacterBody2D


@export var MoveSpeed:= 100
@export var max_health: float = 100.0
@export var iframe_duration: float = 0.6

var health: float
var _invuln_until: float = 0.0

func _ready() -> void:
	health = max_health
	if not is_in_group("player"):
		add_to_group("player")

func take_damage(amount: float) -> void:
	var now := Time.get_ticks_msec() * 0.001
	if now < _invuln_until:
		return
	_invuln_until = now + iframe_duration
	health -= amount
	_flash()

	if health <= 0.0:
		_die()

func _flash() -> void:
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 0.3, 0.3), 0.06)
	t.tween_property(self, "modulate", Color.WHITE, 0.15)

func _die() -> void:
	# Override for game over logic
	set_physics_process(false)
	modulate = Color(0.4, 0.4, 0.4, 0.6)

func _physics_process(delta: float) -> void:
	var direction :=Input.get_vector("Left", "Right","Up","Down")
	if direction:
		velocity = direction * MoveSpeed
	else:
		velocity.y = move_toward(velocity.y, 0, MoveSpeed)
		velocity.x = move_toward(velocity.x, 0, MoveSpeed)

	move_and_slide()
