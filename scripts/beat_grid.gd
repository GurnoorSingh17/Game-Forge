class_name BeatGrid
extends Node

const CELL_COUNT := 8          # 4 beats × 2 sub-slots
const BEAT_COUNT := 4

@export var boomerang_ref: Boomerang
@export var player_ref: Node2D
@export var world_ref: Node2D

var cells: Array = []
var _context: AbilityContext

func _ready() -> void:
	cells.resize(CELL_COUNT)
	_install_defaults()
	Conductor.cell_ticked.connect(_on_cell_ticked)

	if boomerang_ref == null or player_ref == null or world_ref == null:
		push_warning("BeatGrid: refs missing")
		return

	_context = AbilityContext.new()
	_context.boomerang = boomerang_ref
	_context.player = player_ref
	_context.grid = self
	_context.world = world_ref

func _install_defaults() -> void:
	var t := ThrowAbility.new()
	t.display_name = "THROW"
	cells[0] = t

	var c := CatchAbility.new()
	c.display_name = "CATCH"
	cells[CELL_COUNT - 1] = c

# cells 0 and 7 are throw/catch. Cells 1 and 6 are locked-empty visual fillers.
func is_locked_cell(i: int) -> bool:
	return i == 0 or i == 1 or i == 6 or i == 7

func is_free_cell(i: int) -> bool:
	return i >= 2 and i <= 5

func _on_cell_ticked(idx: int) -> void:
	if _context == null:
		return
	var a: Ability = cells[idx]
	if a != null:
		a.execute(_context)

func set_cell(i: int, a: Ability) -> void:
	if not is_free_cell(i):
		push_warning("BeatGrid: cell %d is not placeable" % i)
		return
	cells[i] = a

func get_cell(i: int) -> Ability:
	if i < 0 or i >= CELL_COUNT:
		return null
	return cells[i]

func find_cell_of(ability_class) -> int:
	for i in CELL_COUNT:
		var a: Ability = cells[i]
		if a != null and is_instance_of(a, ability_class):
			return i
	return -1

# In beats. Throw at cell 0 (beat 0), catch at cell 7 (beat 3.5) → lap = 3.5
func lap_length_beats() -> float:
	var tc := find_cell_of(ThrowAbility)
	var cc := find_cell_of(CatchAbility)
	if tc < 0: tc = 0
	if cc < 0: cc = CELL_COUNT - 1
	return float((cc - tc + CELL_COUNT) % CELL_COUNT) / 2.0
