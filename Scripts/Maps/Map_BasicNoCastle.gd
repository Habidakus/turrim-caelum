extends Map

var pathArray : Array = []
var currentPathIndex = 0

func start_game(rng : RandomNumberGenerator):
	pathArray = []
	pathArray.append(generate_path(get_screen_edge(rng), get_screen_edge(rng), 0, rng))

func game_over():
	pass

func current_path() -> Curve2D:
	if pathArray.size() == 1:
		return pathArray[0]
	else:
		currentPathIndex += 1
		return pathArray[currentPathIndex % pathArray.size()]

func has_castle() -> bool:
	return false

func on_mob_spawn(mobId : int, rng : RandomNumberGenerator):
	if mobId % 11 == 0:
		var increase = (mobId % 121 == 0)
		pathArray.append(generate_path(get_screen_edge(rng), get_screen_edge(rng), mobId, rng))
		if increase != true:
			pathArray.remove_at(0)

func get_screen_edge(rng : RandomNumberGenerator) -> Vector2:
	if rng.randi() % 2 == 1:
		var x = 0
		if rng.randi() % 2 == 1:
			x = owner.screen_size.x
		var y = rng.randi() % int(owner.screen_size.y)
		return Vector2(x, y)
	else:
		var y = 0
		if rng.randi() % 2 == 1:
			y = owner.screen_size.y
		var x = rng.randi() % int(owner.screen_size.x)
		return Vector2(x, y)

func add_path_point(start: Vector2, end: Vector2, desired_length: float, curve : Curve2D, mobId: int, rng: RandomNumberGenerator) -> Curve2D:
	var best_bl = 0
	var best : Curve2D = null
	var buffer = max(20, 400 - mobId)
	var maxPlacement : Vector2 = owner.screen_size - Vector2(buffer, buffer);
	for i in 50:
		var tStart = start
		if rng.randi() % 2 == 1:
			tStart.x += 80;
		else:
			tStart.y += 80;
		tStart.x = clamp(tStart.x, 20, maxPlacement.x)
		tStart.y = clamp(tStart.y, 20, maxPlacement.y)
		var tEnd = end
		if rng.randi() % 2 == 1:
			tEnd.x -= 80;
		else:
			tEnd.y -= 80;
		tEnd.x = clamp(tEnd.x, 20, maxPlacement.x)
		tEnd.y = clamp(tEnd.y, 20, maxPlacement.y)
		var x = rng.randf_range(tStart.x, tEnd.x)
		var y = rng.randf_range(tStart.y, tEnd.y)
		var d : Curve2D = curve.duplicate()
		var insert_point = 1
		if curve.point_count > 2:
			insert_point = rng.randi_range(1, curve.point_count - 1)
		var p = Vector2(x, y)
		var in_p = (curve.get_point_position(insert_point - 1) - p) / 1.5
		var out_p = (curve.get_point_position(insert_point) - p) / 1.5
		d.add_point(p, in_p, out_p, insert_point)
		var bl = absf(desired_length - d.get_baked_length())
		if best == null || bl < best_bl:
			best = d
			best_bl = bl
		if x < 0 || y < 0 || x > owner.screen_size.x || y > owner.screen_size.y:
			print_debug("x y = (", x, ", ", y, ")")
	return best

func request_unique_path(start: Vector2, end: Vector2, pointCount: int, mobId: int, rng: RandomNumberGenerator) -> Curve2D:
	var c : Curve2D = Curve2D.new()
	c.add_point(start)
	c.add_point(end)
	var totalPoints = pointCount + 4
	for i in totalPoints:
		var length : float = 1800.0 + (1200.0 * (i + 1.0) / totalPoints)
		var n : Curve2D = add_path_point(start, end, length, c, mobId, rng)
		c = n
		
	return c
	
func generate_path(start: Vector2, end: Vector2, mobId: int, rng: RandomNumberGenerator) -> Curve2D:
	return request_unique_path(start, end, 4, mobId, rng)
