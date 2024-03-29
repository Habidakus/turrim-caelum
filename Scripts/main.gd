extends Node

#######################################################################
# Learning exercise 
#
# Note: All art & coding was made by me
#       Sound was downloaded from free samples from https://pixabay.com
#######################################################################

@export var mob_scene: PackedScene
@export var player_scene: PackedScene

# TODO List:
#
# Godot Tech to learn:
# - settings screen
#
# Features to add:
# - game outro (score, unlocks, etc...)
# - barriers on the castle (unlocked via upgrades?)
# - meta progression
#   - permanently apply some upgrades
#   - more maps:
#     - maps that start with mob ID at larger numbers 
#     - rocks that will block both enemy paths & blow up the player
#     - walls (like rocks, but much longer)
#     - hostile zones that would blow up the player but allow mobs to pass through
# - display stats while in advancement selection screen (and on end screen)
# - more advancements:
#   - multi shot
#   - power shot
#   - hailstorm
#   - movement-based power attacks (move in circle, move in star pattern, etc...)
# - Add more curses
# Bugs to fix:
# - Add sound & VFX feedback when selecting upgrade card
# - fix collision bug on larger enemies (or is it enemies at 45 degree angles?)

var screen_size;
var rng = RandomNumberGenerator.new()
var money = 0
var spendable_money : int = 0
var score = 0
var mobId : int = 1
var secondsPerMonster : float = 2.0
var monster_spawnrate_increase : int = 0
var rolling_mob_health_average : float = 0
var player : Player = null
var map : Map = null

var freeXp: int = 1
var freeXpCounter : int = 0

var highscore_list : Array = []
var highscore_filepath = "user://highscores.dat"

var possible_cards = [
	load("res://Data/Cards/autospend_once.tres"),
	load("res://Data/Cards/bulletRange.tres"),
	load("res://Data/Cards/bulletRange_slowerSpeed.tres"),
	load("res://Data/Cards/fasterBullets.tres"),
	load("res://Data/Cards/fasterBullets_lessDamage.tres"),
	load("res://Data/Cards/fasterPlayer_a1.tres"),
	load("res://Data/Cards/fasterPlayer_a2.tres"),
	load("res://Data/Cards/fasterFireRate_a1.tres"),
	load("res://Data/Cards/lethalBullets.tres"),
	load("res://Data/Cards/lethalBullets_lessRange.tres"),
	load("res://Data/Cards/lethalBullets_slowerRate.tres"),
	load("res://Data/Cards/revealFinalApproachSooner_a1.tres"),
]

var possible_curses = [
	load("res://Data/Cards/curse_idAdvance_minor.tres"),
	load("res://Data/Cards/curse_idAdvance_medium.tres"),
	load("res://Data/Cards/curse_idAdvance_hard.tres"),
	load("res://Data/Cards/curse_spawnRate_minor.tres"),
	load("res://Data/Cards/curse_spawnRate_medium.tres"),
	load("res://Data/Cards/curse_spawnRate_hard.tres"),
]

signal increase_score(amount : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	$MobTimer.timeout.connect(_on_mob_timer_timeout)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for card in possible_cards.size():
		if possible_cards[card] == null:
			print_debug("BAD CARD (#", card ,")")
	for card in possible_curses.size():
		if possible_curses[card] == null:
			print_debug("BAD CURSE (#", card ,")")

func start_game():
	rng.seed = Time.get_ticks_msec()
	money = 0
	spendable_money = 0
	score = 0
	mobId = 1
	monster_spawnrate_increase = 0
	rolling_mob_health_average = 0
	freeXp = 1
	freeXpCounter = 0
	
	# Create the player
	player = player_scene.instantiate()
	add_child(player)
	screen_size = player.get_viewport_rect().size
	player.position = screen_size / 2.0
	
	map = $Maps/Map_Basic
	map.start_game(rng)
	
	$MobTimer.wait_time = secondsPerMonster
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
	var increase : float = float(min(200, mobId)) * (advanceAmount - 1.0)
	mobId += int(round(increase))

func advance_spawnrate(advanceAmount : float):
	var increase : float = float(min(100, mobId)) * (advanceAmount - 1.0)
	monster_spawnrate_increase += int(round(increase))

func current_path() -> Curve2D:
	return map.current_path()

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
	var bonusScore = 0
	freeXpCounter += 1
	if freeXpCounter % freeXp == 0:
		bonusScore = 1
		freeXpCounter = 0
		freeXp += 1
	
	spawn_mob(mobId, 0, current_path(), bonusScore)
	map.on_mob_spawn(mobId, rng)
	mobId += 1
	
	$MobTimer.wait_time = lerp(secondsPerMonster, secondsPerMonster / 5.0, (monster_spawnrate_increase - 50) / 850.0)
	monster_spawnrate_increase += 1

func spawn_mob(id, dist, path, bonusScore : int) -> Mob:
	var mob : Mob = mob_scene.instantiate()
	mob.position = path.sample_baked(dist)
	var speed_scale = rng.randf_range(0.8, 1.2)
	var final_target : Node2D = player
	if map.has_castle():
		final_target = map.get_castle() 
		
	mob.set_target(final_target, speed_scale, id, path, dist, map, player, bonusScore, rng)
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
	map.game_over()
	player.queue_free()
	
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

func populate_high_score():
	highscore_list.sort_custom(highscore_list_sorter)
	var count = highscore_list.size()
	if count > 12:
		count = 12
	var hud_high_score : Array = []
	for entry in count:
		hud_high_score.append(highscore_list[entry])
	%HUD.populate_high_score(hud_high_score)

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
