class_name ThrowIndicator
extends Node2D

@export var player: Node2D
@export var boomerang: Boomerang
@export var preview: BoomerangPreview

func _process(_delta: float) -> void:
	if player == null or boomerang == null or preview == null:
		return
	if not boomerang.is_held():
		preview.hide_path()
		return

	var ppos := player.global_position
	var mpos := get_global_mouse_position()
	var pull := mpos - ppos
	var pull_len := pull.length()
	if pull_len < 0.001:
		preview.hide_path()
		return

	var info := ThrowAbility.compute_pull(pull_len)
	if not info["valid"]:
		preview.hide_path()
		return

	var throw_dir := -(pull / pull_len)
	preview.show_path(ppos, throw_dir, info["range"], info["curve"], ppos)
