extends Map

@export var castle_scene: PackedScene
@export var wall_scene: PackedScene

var castle = null
var pathArray : Array = []
var currentPathIndex = 0
var rocks : Array = []
var oneThird : float = 1.0 / 3.0
var edgeXLow : Vector2
var edgeXHigh : Vector2
var edgeYLow : Vector2
var edgeYHigh : Vector2
var holeXLow : Vector2
var holeXHigh : Vector2
var holeYLow : Vector2
var holeYHigh : Vector2

func get_map_name() -> String:
	return "Walls with Castle"

func get_hole_loc(edge : Vector2) -> Vector2:
	return edge.lerp(owner.screen_size / 2, oneThird)

func get_rock_pos(edge : Vector2, fraction: float) -> Vector2:
	var hole : Vector2 = get_hole_loc(edge)
	var holeStart : Vector2 = hole.move_toward(edge, 32)
	var holeEnd : Vector2 = hole.move_toward(owner.screen_size/2, 32)
	if fraction < oneThird:
		return lerp(edge, holeStart, fraction / oneThird)
	else:
		return lerp(holeEnd, owner.screen_size/2, (fraction - oneThird) / (2.0 * oneThird))

func add_rock(rng : RandomNumberGenerator, edge : Vector2, fraction : float):
	var rock : Area2D = wall_scene.instantiate()
	rock.position = get_rock_pos(edge, fraction)
	rock.rotation = rng.randf() * 360.0
	rock.scale *= 1.0 - rng.randf() * 0.2
	rocks.append(rock)
	owner.add_child(rock)
	rock.add_to_group("rock")

func start_game(rng : RandomNumberGenerator, mainLoop) -> Vector2:
	
	# Create the castle
	castle = castle_scene.instantiate()
	add_child(castle)
	castle.position = owner.screen_size - Vector2(20,20)
	var centerOfScreen : Vector2 = owner.screen_size / 2
	
	mainLoop.timeDilation = mainLoop.timeDilation * 2.0 / 3.0
	
	edgeXLow = Vector2(10, centerOfScreen.y)
	edgeXHigh = Vector2(owner.screen_size.x - 10, centerOfScreen.y)
	edgeYLow = Vector2(centerOfScreen.x, 10)
	edgeYHigh = Vector2(centerOfScreen.x, owner.screen_size.y - 10)
	
	var rocksOnXAxis : int = 14
	for i in rocksOnXAxis:
		var fraction : float = float(i) / float(rocksOnXAxis)
		add_rock(rng, edgeXLow, fraction)
		add_rock(rng, edgeXHigh, fraction)
	var rocksOnYAxis : int = 10
	for i in rocksOnYAxis:
		var fraction : float = float(i) / float(rocksOnYAxis)
		add_rock(rng, edgeYLow, fraction)
		add_rock(rng, edgeYHigh, fraction)
	
	holeXLow = (get_rock_pos(edgeXLow, 4.0 / rocksOnXAxis) + get_rock_pos(edgeXLow, 5.0 / rocksOnXAxis)) / 2
	holeXHigh = (get_rock_pos(edgeXHigh, 4.0 / rocksOnXAxis) + get_rock_pos(edgeXHigh, 5.0 / rocksOnXAxis)) / 2
	holeYLow = (get_rock_pos(edgeYLow, 3.0 / rocksOnYAxis) + get_rock_pos(edgeYLow, 4.0 / rocksOnYAxis)) / 2
	holeYHigh = (get_rock_pos(edgeYHigh, 3.0 / rocksOnYAxis) + get_rock_pos(edgeYHigh, 4.0 / rocksOnYAxis)) / 2

	pathArray = []
	pathArray.append(generate_path(rng))

	return get_castle().position - Vector2(32, 32)

func game_over():
	if castle != null:
		castle.queue_free()
		castle = null
	for rock in rocks:
		rock.queue_free()
	rocks = []
	
func current_path() -> Curve2D:
	if pathArray.size() == 1:
		return pathArray[0]
	else:
		return pathArray[currentPathIndex % pathArray.size()]

func has_castle() -> bool:
	return true

func get_castle() -> Area2D:
	return castle

func on_mob_spawn(mobId : int, rng : RandomNumberGenerator):
	if mobId % 11 == 0:
		currentPathIndex += 1
		pathArray.append(generate_path(rng))
		
		var increase = (mobId % 121 == 0)
		if increase != true:
			pathArray.remove_at(0)

func pick_point(samplePoint: Vector2, rng: RandomNumberGenerator) -> Vector2:
	var x = rng.randf_range(20, holeYLow.x - 64)
	var y = rng.randf_range(20, holeXLow.y - 64)
	var point = Vector2(x, y)
	if in_same_quad(samplePoint, point):
		return point

	point.x = owner.screen_size.x - point.x
	if in_same_quad(samplePoint, point):
		return point

	point.y = owner.screen_size.y - point.y
	if in_same_quad(samplePoint, point):
		return point

	point.x = owner.screen_size.x - point.x
	return point

func is_better_point(our_offset : float, our_isBad : bool, our_howClose : float, their_offset : float, their_isBad : bool, their_howClose : float) -> bool:
	# if one of the two points is too close to the castle, return the other one
	if our_isBad != their_isBad:
		return their_isBad
	# otherwise if one got closer to rocks than another, return the one that avoided the rocks
	if our_howClose != their_howClose:
		return their_howClose > our_howClose
	# otherwise whichever one is closer to the right distance is the better one
	return our_offset < their_offset

func in_same_quad(p1 : Vector2, p2 : Vector2) -> bool:
	var lowX1 : bool = (p1.x * 2) < owner.screen_size.x
	var lowX2 : bool = (p2.x * 2) < owner.screen_size.x
	if lowX1 != lowX2:
		return false
	var lowY1 : bool = (p1.y * 2) < owner.screen_size.y
	var lowY2 : bool = (p2.y * 2) < owner.screen_size.y
	if lowY1 != lowY2:
		return false
	return true

func add_path_point(desired_length: float, curve : Curve2D, rng: RandomNumberGenerator) -> Curve2D:
	var best_bl : float = 0
	var best_isBad : bool = true
	var best_howClose : float = 0
	var best : Curve2D = null
	
	var viablePoints = []
	for pointIndex in curve.point_count - 1:
		if in_same_quad(curve.get_point_position(pointIndex), curve.get_point_position(pointIndex + 1)):
			viablePoints.append(pointIndex)
	
	for i in 50:
		var d : Curve2D = curve.duplicate()
		var insert_point : int = viablePoints.pick_random()
		var p = pick_point(curve.get_point_position(insert_point), rng)
		d.add_point(p, Vector2.ZERO, Vector2.ZERO, insert_point + 1)
		var bl = absf(desired_length - d.get_baked_length())
		var isBad : bool = p.distance_squared_to(castle.position) < 64 * 64

		# Try to not have swerve mobs swerve into rocks
		var howClose : float = 0
		for rock in rocks:
			var closeToRocks : float = (64 * 64) - p.distance_squared_to(rock.position)
			if closeToRocks > howClose:
				howClose = closeToRocks
					
		if best == null || is_better_point(bl, isBad, howClose, best_bl, best_isBad, best_howClose):
			best = d
			best_bl = bl
			best_isBad = isBad
			best_howClose = howClose
	return best

func request_unique_path(start: Vector2, end: Vector2, pointCount: int, _mobId: int, rng: RandomNumberGenerator) -> Curve2D:
	var c : Curve2D = Curve2D.new()
	c.add_point(start)
	if rng.randi() % 2 == 1:
		c.add_point(holeXLow - Vector2(0, 32))
		c.add_point(holeXLow + Vector2(0, 32))
		c.add_point(holeYHigh - Vector2(32, 0))
		c.add_point(holeYHigh + Vector2(32, 0))
	else:
		c.add_point(holeYLow - Vector2(32, 0))
		c.add_point(holeYLow + Vector2(32, 0))
		c.add_point(holeXHigh - Vector2(0, 32))
		c.add_point(holeXHigh + Vector2(0, 32))
	c.add_point(end)
	
	var totalPoints = pointCount + 4
	for i in totalPoints:
		var length : float = 1800.0 + (1200.0 * (i + 1.0) / totalPoints)
		var n : Curve2D = add_path_point(length, c, rng)
		c = n
	return c

func generate_path(rng: RandomNumberGenerator) -> Curve2D:
	
	var start = Vector2(0,0)
	if rng.randi() % 2 == 1:
		start.x = rng.randi_range(0, (owner.screen_size.x / 2) - 64)
	else:
		start.y = rng.randi_range(0, (owner.screen_size.y / 2) - 64)
			
	var c = request_unique_path(start, get_castle().position, 4, 0, rng)
	return c
