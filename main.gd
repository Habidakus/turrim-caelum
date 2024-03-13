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
var spendable_money : int = 0
var score = 0
var mobId = 1
var player = null
var castle = null

var pathArray : Array = []
var currentPathIndex = 0
var player_paused : bool = false

signal increase_score(amount : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	$MobTimer.timeout.connect(_on_mob_timer_timeout)
	$TitleTimer.timeout.connect(_on_title_timer_timeout)
	get_tree().paused = true
	player_paused = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	$TitleTimer.wait_time = 1
	$TitleTimer.start()

func start_game():
	money = 0
	spendable_money = 0
	score = 0
	mobId = 1
	get_tree().paused = false
	player_paused = false
	
	# Create the player
	player = player_scene.instantiate()
	add_child(player)
	screen_size = player.get_viewport_rect().size
	player.position = screen_size / 2.0
	
	# Create the castle
	castle = castle_scene.instantiate()
	add_child(castle)
	castle.position = screen_size - Vector2(20,20)
	
	pathArray = []
	pathArray.append(generate_path(Vector2(0,0), castle.position))
	
	$MobTimer.start()
	$HUD.set_score(0)

func add_path_point(start: Vector2, end: Vector2, desired_length: float, curve : Curve2D) -> Curve2D:
	var best_bl = 0
	var best : Curve2D = null
	for i in 50:
		var tStart = start
		if rng.randi() % 2 == 1:
			tStart.x += 40;
		else:
			tStart.y += 40;
		var tEnd = end
		if rng.randi() % 2 == 1:
			tEnd.x -= 80;
		else:
			tEnd.y -= 80;
		var x = rng.randf_range(tStart.x, tEnd.x)
		var y = rng.randf_range(tStart.y, tEnd.y)
		var d : Curve2D = curve.duplicate()
		var insert_point = 1
		if curve.point_count > 2:
			insert_point = rng.randi_range(1, curve.point_count - 1)
		d.add_point(Vector2(x, y), Vector2(0,0), Vector2(0,0), insert_point)
		var bl = absf(desired_length - d.get_baked_length())
		if best == null || bl < best_bl:
			best = d
			best_bl = bl
	return best

func generate_path(start: Vector2, end: Vector2) -> Curve2D:
	var two_points : Curve2D = Curve2D.new()
	two_points.add_point(start)
	two_points.add_point(end)
	
	var three_points = add_path_point(start, end, 1800.0, two_points);
	var four_points = add_path_point(start, end, 2200.0, three_points);
	var five_points = add_path_point(start, end, 2600.0, four_points);
	var six_points = add_path_point(start, end, 3000.0, five_points);
	
	return six_points

func current_path() -> Curve2D:
	if pathArray.size() == 1:
		return pathArray[0]
	else:
		currentPathIndex += 1
		return pathArray[currentPathIndex % pathArray.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if player != null:
			get_tree().paused = (get_tree().paused == false)
			player_paused = get_tree().paused
		return # gobble up the "Pause" press, so we don't accidently start the game
	if player_paused:
		return
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

func play_impact_sound():
	$ImpactPlayer.play()

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
	player_paused = false
	$TitleTimer.wait_time = 3
	$TitleTimer.start()

func _on_increase_score(amount):
	money += amount
	if money >= 23:
		spendable_money += 1
		money -= 23
		$HUD.set_money(spendable_money)
	score += amount
	$HUD.set_score(score)
