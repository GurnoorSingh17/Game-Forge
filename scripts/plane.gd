extends Node2D

const BOOMBA_SCENE = preload("res://scenes/boomba.tscn")

@export var travel_distance: float = 1200.0
@export var travel_duration: float = 3.0
@export var drop_count: int = 3
@export var drop_y_offset: float = 400.0

var _t: float = 0.0
var _drop_times: Array = []
var _start_x: float
var _y: float

func _ready() -> void:
	_start_x = global_position.x
	_y = global_position.y
	for i in drop_count:
		var f := (float(i) + 0.5) / float(drop_count)
		_drop_times.append(f * travel_duration)
	_drop_times.sort()

func _process(delta: float) -> void:
	_t += delta
	var f := _t / travel_duration
	global_position.x = _start_x + f * travel_distance

	while _drop_times.size() > 0 and _t >= _drop_times[0]:
		_drop_times.pop_front()
		_drop()

	if f >= 1.0:
		queue_free()

func _drop() -> void:
	var b = BOOMBA_SCENE.instantiate()
	get_parent().add_child(b)
	var landing := Vector2(global_position.x, _y + drop_y_offset)
	b.begin_fall(global_position, landing, 0.8)
