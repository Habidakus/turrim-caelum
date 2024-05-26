extends Map

@export var castle_scene: PackedScene
@export var wall_scene: PackedScene

var castle = null
var pathArray : Array = []
var currentPathIndex = 0
var rocks : Array = []

func get_map_name() -> String:
	return "Rocks with Castle"

func start_game(rng : RandomNumberGenerator, mainLoop) -> Vector2:
	
	# Create the castle
	castle = castle_scene.instantiate()
	add_child(castle)
	castle.position = owner.screen_size - Vector2(20,20)
	
	mainLoop.timeDilation = mainLoop.timeDilation * 2.0 / 3.0
	
	pathArray = []
	pathArray.append(generate_path(Vector2(0,0), castle.position, 0, rng))
	pathArray.append(generate_path(Vector2(owner.screen_size.x / 3,0), castle.position, 0, rng))
	pathArray.append(generate_path(Vector2(0,owner.screen_size.y / 3), castle.position, 0, rng))
	
	for i in 150:
		var rock : Area2D = wall_scene.instantiate()
		var bestLoc : Vector2
		var bestRockDist : float = 0
		var consideredEnough : bool = false
		var considerCount : int = 0
		while consideredEnough == false:
			var x : float = 20 + rng.randf() * (owner.screen_size.x - 40)
			var y : float = 20 + rng.randf() * (owner.screen_size.y - 40)
			var p = Vector2(x, y)
			var closestDist : float = owner.screen_size.x + owner.screen_size.y
			for path : Curve2D in pathArray:
				var dist : float = path.get_closest_point(p).distance_squared_to(p)
				if closestDist > dist:
					closestDist = dist
			if closestDist > bestRockDist:
				bestRockDist = closestDist
				bestLoc = p
			considerCount += 1
			if considerCount > 50 && bestRockDist > 32:
				consideredEnough = true
		rock.position = bestLoc
		rock.rotation = rng.randf() * 360.0
		rock.scale *= 1.0 - rng.randf() * 0.2
		rocks.append(rock)
		owner.add_child(rock)
		rock.add_to_group("rock")

	var playerSpawn : Vector2 = get_castle().position - Vector2(32, 32)
	var bestPlayerDist : float = playerSpawn.distance_squared_to(owner.screen_size / 2.0)
	for path : Curve2D in pathArray:
		var length = path.get_baked_length()
		var loc = path.sample_baked(length / 2.0)
		var dist : float = loc.distance_squared_to(owner.screen_size / 2.0)
		if dist < bestPlayerDist:
			bestPlayerDist = dist
			playerSpawn = loc
	return playerSpawn

func game_over():
	if castle != null:
		castle.queue_free()
		castle = null
	for rock in rocks:
		rock.queue_free()
	rocks = []
	
func current_path() -> Curve2D:
	return pathArray[currentPathIndex % pathArray.size()]

func has_castle() -> bool:
	return true

func get_castle() -> Area2D:
	return castle

func on_mob_spawn(mobId : int, _rng : RandomNumberGenerator):
	if mobId % 11 == 0:
		currentPathIndex += 1

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

func is_better_point(our_offset : float, our_isBad : bool, our_isWrong : bool, their_offset : float, their_isBad : bool, their_isWrong : bool) -> bool:
	# if one of the two points is too close to the castle, return the other one
	if our_isBad != their_isBad:
		return their_isBad
	# if one of their points is close to another path's point, that's annoying
	if our_isWrong != their_isWrong:
		return their_isWrong
	# otherwise whichever one is closer to the right distance is the better one
	return our_offset < their_offset

func add_path_point(start: Vector2, end: Vector2, desired_length: float, curve : Curve2D, mobId: int, rng: RandomNumberGenerator) -> Curve2D:
	var best_bl : float = 0
	var best_isBad : bool = true
	var best_isWrong : bool = true
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
				
		var isWrongDist : float = owner.screen_size.x + owner.screen_size.y
		for previousPath in pathArray:
			for previousPointIndex in previousPath.point_count:
				var dist : float = p.distance_to(previousPath.get_point_position(previousPointIndex))
				if dist < isWrongDist:
					isWrongDist = dist
		
		var isWrong : bool = isWrongDist < buffer

		# Try to not have swerve mobs swerve into rocks
		if !isWrong:
			for rock in rocks:
				if p.distance_squared_to(rock.position) < buffer * buffer:
					isWrong = true
					break
					
		if best == null || is_better_point(bl, isBad, isWrong, best_bl, best_isBad, best_isWrong):
			best = d
			best_bl = bl
			best_isBad = isBad
			best_isWrong = isWrong
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
