extends Map

@export var castle_scene: PackedScene

var castle = null
var pathArray : Array = []
var currentPathIndex = 0

func get_map_name() -> String:
	return "Castle"

func start_game(rng : RandomNumberGenerator, _mainLoop) -> Vector2:
	
	# Create the castle
	castle = castle_scene.instantiate()
	add_child(castle)
	castle.position = owner.screen_size - Vector2(20,20)
	
	pathArray = []
	pathArray.append(generate_path(Vector2(0,0), castle.position, 0, rng))
	return owner.screen_size / 2.0

func game_over():
	if castle != null:
		castle.queue_free()
		castle = null
	
func current_path() -> Curve2D:
	if pathArray.size() == 1:
		return pathArray[0]
	else:
		currentPathIndex += 1
		return pathArray[currentPathIndex % pathArray.size()]

func has_castle() -> bool:
	return true

func get_castle() -> Area2D:
	return castle

func on_mob_spawn(mobId : int, rng : RandomNumberGenerator):
	if mobId % 11 == 0:
		var increase = (mobId % 121 == 0)
		var start = Vector2(0,0)
		if rng.randi() % 2 == 1:
			start.x = rng.randi_range(0, owner.screen_size.x)
		else:
			start.y = rng.randi_range(0, owner.screen_size.y)
		pathArray.append(generate_path(start, castle.position, mobId, rng))
		if increase != true:
			pathArray.remove_at(0)

func pick_point(start: Vector2, end: Vector2, rng: RandomNumberGenerator) -> Vector2:
	var tStart = start
	if rng.randi() % 2 == 1:
		tStart.x += 80;
	else:
		tStart.y += 80;
	tStart.x = clamp(tStart.x, 20, owner.screen_size.x - 20)
	tStart.y = clamp(tStart.y, 20, owner.screen_size.y - 20)
	var tEnd = end
	if rng.randi() % 2 == 1:
		tEnd.x -= 80;
	else:
		tEnd.y -= 80;
	tEnd.x = clamp(tEnd.x, 20, owner.screen_size.x - 20)
	tEnd.y = clamp(tEnd.y, 20, owner.screen_size.y - 20)
	var x = rng.randf_range(tStart.x, tEnd.x)
	var y = rng.randf_range(tStart.y, tEnd.y)
	return Vector2(x, y)

func is_better_point(our_offset : float, our_isBad : bool, their_offset : float, their_isBad : bool) -> bool:
	# if one of the two points is too close to the castle, return the other one
	if our_isBad != their_isBad:
		return their_isBad
	# otherwise whichever one is closer to the right distance is the better one
	return our_offset < their_offset

func add_path_point(start: Vector2, end: Vector2, desired_length: float, curve : Curve2D, mobId: int, rng: RandomNumberGenerator) -> Curve2D:
	var best_bl : float = 0
	var best_isBad : bool = true
	var best : Curve2D = null
	var buffer = max(32, 400 - mobId)
	for i in 50:
		var d : Curve2D = curve.duplicate()
		var insert_point = 1
		if curve.point_count > 2:
			insert_point = rng.randi_range(1, curve.point_count - 1)
		var p = pick_point(start, end, rng)
		var in_p = (curve.get_point_position(insert_point - 1) - p) / 1.5
		var out_p = (curve.get_point_position(insert_point) - p) / 1.5
		d.add_point(p, in_p, out_p, insert_point)
		var bl = absf(desired_length - d.get_baked_length())
		var isBad : bool = p.distance_to(castle.position) < buffer
		if best == null || is_better_point(bl, isBad, best_bl, best_isBad):
			best = d
			best_bl = bl
			best_isBad = isBad
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
