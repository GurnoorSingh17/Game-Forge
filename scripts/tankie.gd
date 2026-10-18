class_name Tankie
extends Enemy

func _ready() -> void:
	max_health = 250.0
	move_speed = 40.0
	contact_damage = 8.0
	knockback_resistance = 0.7
	super()
