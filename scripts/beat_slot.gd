extends PanelContainer

var grid: BeatGrid
var cell_index: int = 0
var _last: Ability = null

@onready var label: Label = $Label
@onready var highlight: ColorRect = $Highlight

func set_data(g: BeatGrid, i: int) -> void:
	grid = g
	cell_index = i
	refresh()

func _process(_delta: float) -> void:
	if grid == null:
		return
	var a: Ability = grid.get_cell(cell_index)
	if a != _last:
		_last = a
		_render(a)

func refresh() -> void:
	if grid == null:
		return
	_render(grid.get_cell(cell_index))

func _render(a: Ability) -> void:
	var locked := grid and grid.is_locked_cell(cell_index)
	if a != null:
		label.text = a.display_name
		modulate = a.color if a.color.a > 0.0 else Color.WHITE
	elif locked:
		label.text = "—"
		modulate = Color(1, 1, 1, 0.2)
	else:
		label.text = "—"
		modulate = Color(1, 1, 1, 0.5)

func _can_drop_data(_pos, data) -> bool:
	if grid == null: return false
	if not grid.is_free_cell(cell_index): return false
	return data is Dictionary and data.has("ability")

func _drop_data(_pos, data) -> void:
	if grid == null: return
	grid.set_cell(cell_index, data["ability"])

func _get_drag_data(_pos):
	if grid == null: return null
	if not grid.is_free_cell(cell_index): return null
	var a: Ability = grid.get_cell(cell_index)
	if a == null or a.is_locked(): return null

	var preview := Label.new()
	preview.text = a.display_name
	set_drag_preview(preview)
	grid.set_cell(cell_index, null)
	return {"ability": a}
