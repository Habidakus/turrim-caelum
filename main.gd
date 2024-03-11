extends Node

#######################################################################
# Learning exercise 
#
# Note: All art & coding was made by me
#       Sound was downloaded from free samples from https://pixabay.com
#######################################################################

@export var mob_scene: PackedScene
@export var player_scene: PackedScene
@export var castle_scene: PackedScene

var screen_size;
var rng = RandomNumberGenerator.new()
var money = 0
var score = 0
var mobId = 1
var player = null
var castle = null

var pathArray : Array = []
var currentPathIndex = 0

signal increase_score(amount : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	$MobTimer.timeout.connect(_on_mob_timer_timeout)
	$TitleTimer.timeout.connect(_on_title_timer_timeout)
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	$TitleTimer.wait_time = 1
	$TitleTimer.start()

func start_game():
	money = 0
	score = 0
	mobId = 1
	get_tree().paused = false
	
	# Create the player
	player = player_scene.instantiate()
	add_child(player)
	screen_size = player.get_viewport_rect().size
	player.position = screen_size / 2.0
	
	# Create the castle
	castle = castle_scene.instantiate()
	add_child(castle)
	castle.position = screen_size - Vector2(20,20)
	
	pathArray.append(generate_path(Vector2(0,0), castle.position))
	
	$MobTimer.start()
	$HUD.set_score(0)

func generate_path(start: Vector2, end: Vector2) -> Curve2D:
	var curve : Curve2D = Curve2D.new()
	curve.add_point(start)
	curve.add_point(end)
	var best_bl = 0
	var best : Curve2D = null
	
	for i in 50:
		var x = rng.randf_range(start.x, end.x)
		var y = rng.randf_range(start.y, end.y)
		var d : Curve2D = curve.duplicate()
		d.add_point(Vector2(x, y), Vector2(0,0), Vector2(0,0), 1)
		var bl = absf(1800.0 - d.get_baked_length())
		if best == null || bl < best_bl:
			best = d
			best_bl = bl
	curve = best
	best = null
	
	for i in 50:
		var x = rng.randf_range(start.x, end.x)
		var y = rng.randf_range(start.y, end.y)
		var d : Curve2D = curve.duplicate()
		d.add_point(Vector2(x, y), Vector2(0,0), Vector2(0,0), rng.randi_range(1, 2))
		var bl = absf(2200.0 - d.get_baked_length())
		if best == null || bl < best_bl:
			best = d
			best_bl = bl
	curve = best
	best = null
	
	for i in 50:
		var x = rng.randf_range(start.x, end.x)
		var y = rng.randf_range(start.y, end.y)
		var d : Curve2D = curve.duplicate()
		d.add_point(Vector2(x, y), Vector2(0,0), Vector2(0,0), rng.randi_range(1, 3))
		var bl = absf(2600.0 - d.get_baked_length())
		if best == null || bl < best_bl:
			best = d
			best_bl = bl
	curve = best
	best = null
	
	for i in 50:
		var x = rng.randf_range(start.x, end.x)
		var y = rng.randf_range(start.y, end.y)
		var d : Curve2D = curve.duplicate()
		d.add_point(Vector2(x, y), Vector2(0,0), Vector2(0,0), rng.randi_range(1, 4))
		var bl = absf(3000.0 - d.get_baked_length())
		if best == null || bl < best_bl:
			best = d
			best_bl = bl
	curve = best
	best = null
	
	return curve

func current_path() -> Curve2D:
	if pathArray.size() == 1:
		return pathArray[0]
	else:
		currentPathIndex += 1
		return pathArray[currentPathIndex % pathArray.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if get_tree().paused && $TitleTimer.is_stopped():
		if Input.is_anything_pressed():
			$HUD.start_game()
			start_game()

func _on_title_timer_timeout():
	$HUD.show_restart()
	$TitleTimer.stop()
	
func _on_mob_timer_timeout():
	spawn_mob(mobId, 0, current_path())
	mobId += 1
	
	if mobId % 11 == 0:
		var increase = (mobId % 121 == 0)
		var start = Vector2(0,0)
		if rng.randi() % 2 == 1:
			start.x = rng.randi_range(0, screen_size.x)
		else:
			start.y = rng.randi_range(0, screen_size.y)
		pathArray.append(generate_path(start, castle.position))
		if increase != true:
			pathArray.remove_at(0)
		
func spawn_mob(id, dist, path):
	var mob = mob_scene.instantiate()
	mob.position = path.sample_baked(dist)
	var speed_scale = rng.randf_range(0.8, 1.2)
	mob.set_target($Castle, speed_scale, id, path, dist)
	call_deferred("add_child", mob)

func game_over():
	$AudioStreamPlayer2D.play()
	$MobTimer.stop()
	player.queue_free()
	castle.queue_free()
	$HUD.game_over()
	
	for mob in get_tree().get_nodes_in_group("mob"):
		mob.queue_free()
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.queue_free()
	
	get_tree().paused = true
	$TitleTimer.wait_time = 3
	$TitleTimer.start()

func _on_increase_score(amount):
	money += amount
	score += amount
	$HUD.set_score(score)
