class_name BoomerangPath
extends RefCounted

# t in [0, 1] over the full lap.
#   0.0 → 0.5: outbound, origin → apex, bulging RIGHT of the aim line
#   0.5 → 1.0: return,  apex  → target, bulging LEFT of the aim line
# `sweep` is the peak lateral offset (in pixels).
static func evaluate(t: float, origin: Vector2, aim: Vector2,
					 range_px: float, sweep: float, target: Vector2) -> Vector2:
	var aim_dir := aim.normalized() if aim.length_squared() > 0.001 else Vector2.UP
	var right := aim_dir.orthogonal()
	var apex := origin + aim_dir * range_px

	if t < 0.5:
		var lt := t * 2.0
		var ctrl := origin + aim_dir * (range_px * 0.4) + right * (sweep * 2.0)
		return _quad_bezier(origin, ctrl, apex, lt)
	else:
		var lt := (t - 0.5) * 2.0
		var ctrl := apex + (target - apex) * 0.5 - right * (sweep * 2.0)
		return _quad_bezier(apex, ctrl, target, lt)

static func _quad_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var omt := 1.0 - t
	return p0 * omt * omt + p1 * 2.0 * omt * t + p2 * t * t

static func sample_even_spacing(out_pts: PackedVector2Array,
								origin: Vector2, aim: Vector2,
								range_px: float, sweep: float, target: Vector2,
								spacing: float, max_dots: int) -> void:
	out_pts.clear()
	const DENSE := 200
	var prev := evaluate(0.0, origin, aim, range_px, sweep, target)
	out_pts.append(prev)
	var acc := 0.0
	for i in range(1, DENSE + 1):
		if out_pts.size() >= max_dots:
			break
		var p := evaluate(float(i) / DENSE, origin, aim, range_px, sweep, target)
		acc += prev.distance_to(p)
		if acc >= spacing:
			out_pts.append(p)
			acc = 0.0
		prev = p
