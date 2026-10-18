extends HBoxContainer

@export var abilities: Array[Ability] = []
@export var button_scene: PackedScene

func _ready() -> void:
	if button_scene == null:
		push_error("AbilityBar: button_scene not set")
		return
	for a in abilities:
		if a == null:
			continue
		var btn := button_scene.instantiate()
		btn.ability = a
		add_child(btn)
