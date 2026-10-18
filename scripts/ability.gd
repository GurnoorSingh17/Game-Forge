class_name Ability
extends Resource

@export var display_name: String = "Ability"
@export var icon: Texture2D
@export var color: Color = Color.WHITE

func execute(_ctx: AbilityContext) -> void:
	push_warning("execute() not overridden: " + display_name)

func is_locked() -> bool:
	return false
