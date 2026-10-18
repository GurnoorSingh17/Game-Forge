class_name GlassCannon
extends Enemy

func _ready() -> void:
	max_health = 20.0
	move_speed = 200.0
	contact_damage = 25.0
	knockback_resistance = 0.0
	super()
