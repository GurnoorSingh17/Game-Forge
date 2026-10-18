extends Control

@export var grid: BeatGrid
@export var slot_container: HBoxContainer
@export var playhead: ColorRect
@export var slot_scene: PackedScene

var _slot_nodes: Array = []

func _ready() -> void:
	if grid == null or slot_scene == null:
		push_error("BeatGridUI: grid or slot_scene not set")
		return

	for beat in BeatGrid.BEAT_COUNT:
		var col := VBoxContainer.new()
		col.add_theme_constant_override("separation", 6)
		slot_container.add_child(col)

		for sub in 2:
			var idx := beat * 2 + sub
			var s := slot_scene.instantiate()
			col.add_child(s)
			s.set_data(grid, idx)
			_slot_nodes.append(s)

func _process(_delta: float) -> void:
	if not Conductor.music.playing:
		return
	var b := Conductor.beat()
	if b < 0.0:
		return

	var current := int(floor(b * 2.0)) % BeatGrid.CELL_COUNT
	for i in _slot_nodes.size():
		_slot_nodes[i].highlight.color = (
			Color(1, 1, 0.5, 0.35) if i == current else Color(0, 0, 0, 0)
		)

	if playhead and slot_container:
		var frac := fmod(b * 2.0, float(BeatGrid.CELL_COUNT)) / float(BeatGrid.CELL_COUNT)
		playhead.position.x = slot_container.position.x + frac * slot_container.size.x
