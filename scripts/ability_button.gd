extends TextureButton

@export var ability: Ability

@onready var label: Label = $Label

func _ready() -> void:
	if ability != null:
		label.text = ability.display_name
		if ability.icon:
			texture_normal = ability.icon

func _get_drag_data(_pos: Vector2):
	if ability == null:
		return null

	var preview := TextureButton.new()
	preview.custom_minimum_size = custom_minimum_size
	preview.texture_normal = texture_normal
	preview.modulate.a = 0.85

	var pl := Label.new()
	pl.text = ability.display_name
	pl.set_anchors_preset(Control.PRESET_FULL_RECT)
	pl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.add_child(pl)

	set_drag_preview(preview)
	return {"ability": ability}
