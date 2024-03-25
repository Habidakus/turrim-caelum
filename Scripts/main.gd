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

# TODO List:
#
# Godot Tech to learn:
# - settings screen
# - local persistence
#
# Features to add:
# - game outro (score, unlocks, etc...)
# - high-score board
# - barriers on the castle (unlocked via upgrades?)
# - meta progression
#   - permanently apply some upgrades
#   - more maps:
#     - maps that start with mob ID at larger numbers 
#     - rocks that will block both enemy paths & blow up the player
#     - walls (like rocks, but much longer)
#     - hostile zones that would blow up the player but allow mobs to pass through
# - Quit game button
# - display stats while in advancement selection screen (and on end screen)
# - more advancements:
#   - multi shot
#   - power shot
#   - hailstorm
#   - movement-based power attacks (move in circle, move in star pattern, etc...)
#   - GIVE & TAKE, some advancements increase one stat while takng others away
# - Add more curses
# Bugs to fix:
# - Add sound & VFX feedback when selecting upgrade card
# - fix collision bug on larger enemies (or is it enemies at 45 degree angles?)
# - when mothers spawn children, lerp them to their start locations (so as not to land on player)

var screen_size;
var rng = RandomNumberGenerator.new()
var money = 0
var spendable_money : int = 0
var score = 0
var mobId = 1
var player : Player = null
var castle = null

var highscore_list : Array = []
var highscore_filepath = "user://highscores.dat"

var pathArray : Array = []
var currentPathIndex = 0
var rolling_mob_health_average : float = 0

var possible_cards = [
	load("res://Data/fasterBullets_a1.tres"),
	load("res://Data/fasterBullets_a2.tres"),
	load("res://Data/fasterPlayer_a1.tres"),
	load("res://Data/fasterPlayer_a2.tres"),
	load("res://Data/fasterFireRate_a1.tres"),
	load("res://Data/longLivedBullets_a1.tres"),
	load("res://Data/lethalBullets_a1.tres"),
	load("res://Data/autospend_once.tres"),
	load("res://Data/revealFinalApproachSooner_a1.tres"),
]

var possible_curses = [
	load("res://Data/curse_idAdvance_minor.tres"),
	load("res://Data/curse_idAdvance_medium.tres"),
	load("res://Data/curse_idAdvance_hard.tres"),
]

signal increase_score(amount : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	$MobTimer.timeout.connect(_on_mob_timer_timeout)
	process_mode = Node.PROCESS_MODE_ALWAYS

func start_game():
	money = 0
	spendable_money = 0
	score = 0
	mobId = 1
	rolling_mob_health_average = 0
	
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

func get_show_path_dist() -> float:
	if player != null:
		return player.showPathDist
	else:
		return 0.7

func get_mob_average_health() -> float:
	return rolling_mob_health_average

func advance_id(advanceAmount : float):
	mobId = int(float(mobId) * advanceAmount)

func add_path_point(start: Vector2, end: Vector2, desired_length: float, curve : Curve2D) -> Curve2D:
	var best_bl = 0
	var best : Curve2D = null
	var buffer = max(20, 400 - mobId)
	var maxPlacement : Vector2 = screen_size - Vector2(buffer, buffer);
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
		if x < 0 || y < 0 || x > screen_size.x || y > screen_size.y:
			print_debug("x y = (", x, ", ", y, ")")
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

func start_shopping():
	possible_cards.shuffle()
	var cardA : CardData = null
	var cardB : CardData = null
	var cardC : CardData = null
	for card in possible_cards:
		card.initialize_for_purchase(player, card)
		if card.is_possible(player, card):
			if cardA == null:
				cardA = card
			elif cardB == null:
				cardB = card
			elif cardC == null:
				cardC = card
				
	# We might have advanced so much that we're running
	# out of good cards, so throw a bad card into the mix.
	if cardC == null:
		possible_curses.shuffle()
		for card in possible_curses:
			card.initialize_for_purchase(player, card)
			if card.is_possible(player, card):
				if cardA == null:
					cardA = card
				elif cardB == null:
					cardB = card
				elif cardC == null:
					cardC = card
				
	$HUD.spend_points(cardA, cardB, cardC, player)

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
		
func spawn_mob(id, dist, path) -> Mob:
	var mob : Mob = mob_scene.instantiate()
	mob.position = path.sample_baked(dist)
	var speed_scale = rng.randf_range(0.8, 1.2)
	mob.set_target($Castle, speed_scale, id, path, dist)
	call_deferred("add_child", mob)
	if rolling_mob_health_average == 0:
		rolling_mob_health_average = mob.hp + mob.armor
	else:
		rolling_mob_health_average = (rolling_mob_health_average * 20 + mob.hp + mob.armor) / 21.0
	return mob

# Note - unlike most compare() functions in other languages, this one is only "is lesser" and expects true or false return value
func highscore_list_sorter(a, b):
	# High score to the front
	if a[0] < b[0]:
		return false
	elif a[0] > b[0]:
		return true
	# Tie-break on player's names
	elif a[1] < b[1]:
		return true
	elif a[1] > b[1]:
		return false
	# otherwise equal
	else:
		return false

func game_over():
	$AudioStreamPlayer2D.play()
	$MobTimer.stop()
	player.queue_free()
	castle.queue_free()
	
	var username = "Player One"
	if OS.has_environment("USERNAME"):
		username = OS.get_environment("USERNAME")
	highscore_list.append([score, username])
	highscore_list.sort_custom(highscore_list_sorter)
	while highscore_list.size() > 255:
		highscore_list.remove_at(highscore_list.size() - 1)
	save_highscore()
	
	for mob in get_tree().get_nodes_in_group("mob"):
		mob.queue_free()
	for bullet in get_tree().get_nodes_in_group("bullet"):
		bullet.queue_free()

func player_can_spend_money():
	return spendable_money > 0

func player_bought_autospend():
	return player.autospend

func player_has_spent():
	spendable_money -= 1
	%HUD.set_money(spendable_money)
	%GameStateMachine.switch_state("Playing_Action")
	
func _on_increase_score(amount):
	money += amount
	if money >= 23:
		spendable_money += 1
		money -= 23
		$HUD.set_money(spendable_money)
	score += amount
	$HUD.set_score(score)

func save_highscore():
	var file = FileAccess.open(highscore_filepath, FileAccess.WRITE)
	var count = highscore_list.size()
	if count > 255:
		count = 255		
	highscore_list.sort_custom(highscore_list_sorter)
	file.store_8(count)
	for entry in count:
		var hscore : int = highscore_list[entry][0]
		file.store_32(hscore)
		var hname : String = highscore_list[entry][1]
		file.store_pascal_string(hname)
	file.flush()
	file.close()

func load_highscore():
	if FileAccess.file_exists(highscore_filepath):
		var file = FileAccess.open(highscore_filepath, FileAccess.READ)
		highscore_list = []
		var count : int = file.get_8()
		for i in count:
			var hscore : int = file.get_32()
			var hname : String = file.get_pascal_string()
			var entry : Array = [hscore, hname]
			highscore_list.append(entry)
		highscore_list.sort_custom(highscore_list_sorter)
		file.flush()
		file.close()
