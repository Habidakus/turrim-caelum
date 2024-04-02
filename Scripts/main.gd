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
# - barriers on the castle (unlocked via upgrades?)
# - update high score to include map & kills (and header)
# - meta progression
#   - permanently apply some upgrades
#   - more maps:
#     - screen to select which map to play on
#     - add map name to high score list
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
#   - castle wandering for castle levels
# Bugs to fix:
# - Add sound & VFX feedback when selecting upgrade card
# - fix collision bug on larger enemies (or is it enemies at 45 degree angles?)

var screen_size;
var rng = RandomNumberGenerator.new()
var money = 0
var spendable_money : int = 0
var score = 0
var kills = 0
var spawns = 0
var mobId : int = 1
var secondsPerMonster : float = 2.0
var monster_spawnrate_increase : int = 0
var player : Player = null
var map : Map = null

var freeXp: int = 1
var freeXpCounter : int = 0

#var rollingMobHealthAverage : float = 0
var lastTwentyCreatures = []
var ltcWriteIndex : int = 0

var highscore_list : Array = []
var highscore_filepath = "user://highscores.dat"

# TODO: While useful in testing to explicitly include all or just one card,
# in the future maybe just automatically load all cards in the given directory.
var earlyGameCards = [
	load("res://Data/Cards/autospend_once.tres"),
	load("res://Data/Cards/bulletRange.tres"),
	load("res://Data/Cards/bulletRange_slowerSpeed.tres"),
	load("res://Data/Cards/fasterBullets.tres"),
	load("res://Data/Cards/fasterPlayer_a1.tres"),
	load("res://Data/Cards/fasterFireRate_a1.tres"),
	load("res://Data/Cards/lethalBullets.tres"),
	load("res://Data/Cards/lethalBullets_slowerRate.tres"),
	load("res://Data/Cards/revealFinalApproachSooner_a1.tres"),
]

var lateGameCards = [
	load("res://Data/Cards/fasterPlayer_a2.tres"),
	load("res://Data/Cards/fasterBullets_lessDamage.tres"),
	load("res://Data/Cards/lethalBullets_lessRange.tres"),
	load("res://Data/Cards/curse_idAdvance_minor.tres"),
	load("res://Data/Cards/curse_idAdvance_medium.tres"),
	load("res://Data/Cards/curse_idAdvance_hard.tres"),
	load("res://Data/Cards/curse_spawnRate_minor.tres"),
	load("res://Data/Cards/curse_spawnRate_medium.tres"),
	load("res://Data/Cards/curse_spawnRate_hard.tres"),
	load("res://Data/Cards/curse_tchotchke_airFreshener.tres"),
	load("res://Data/Cards/curse_tchotchke_flightstick.tres"),
	load("res://Data/Cards/curse_tchotchke_flightsuit.tres"),
	load("res://Data/Cards/curse_tchotchke_goggles.tres"),
	load("res://Data/Cards/curse_tchotchke_paintJob.tres"),
	load("res://Data/Cards/curse_tchotchke_subwoofer.tres"),
]

signal increase_score(amount : int)

# Called when the node enters the scene tree for the first time.
func _ready():
	$MobTimer.timeout.connect(_on_mob_timer_timeout)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for card in earlyGameCards.size():
		if earlyGameCards[card] == null:
			print_debug("BAD EARLY GAME CARD (#", card ,")")
	for card in lateGameCards.size():
		if lateGameCards[card] == null:
			print_debug("BAD LATE GAME CARD (#", card ,")")

func start_game():
	rng.seed = Time.get_ticks_msec()
	money = 0
	spendable_money = 0
	score = 0
	kills = 0
	spawns = 0
	mobId = 1
	monster_spawnrate_increase = 0
	#rollingMobHealthAverage = 0
	lastTwentyCreatures = []
	ltcWriteIndex = 0
	freeXp = 1
	freeXpCounter = 0
	
	# Create the player
	player = player_scene.instantiate()
	add_child(player)
	screen_size = player.get_viewport_rect().size
	player.position = screen_size / 2.0
	
	map = $Maps/Map_BasicCastle
	map.start_game(rng)
	
	$MobTimer.wait_time = secondsPerMonster
	$MobTimer.start()
	$HUD.set_score(0)

func get_show_path_dist() -> float:
	if player != null:
		return player.showPathDist
	else:
		return 0.7

#func get_mob_average_health() -> float:
#	return rollingMobHealthAverage

func advance_id(advanceAmount : float):
	var increase : float = float(min(200, mobId)) * (advanceAmount - 1.0)
	mobId += int(round(increase))

func advance_spawnrate(advanceAmount : float):
	var increase : float = float(min(100, mobId)) * (advanceAmount - 1.0)
	monster_spawnrate_increase += int(round(increase))

func current_path() -> Curve2D:
	return map.current_path()

func start_shopping():
	earlyGameCards.shuffle()
	var cardA : CardData = null
	var cardB : CardData = null
	var cardC : CardData = null
	for card in earlyGameCards:
		var worth : PlayerWorth = player.create_player_worth()
		card.initialize_for_purchase(worth)
		if worth.is_player_possible(lastTwentyCreatures, card):
			if cardA == null:
				cardA = card
			elif cardB == null:
				cardB = card
			elif cardC == null:
				cardC = card
				
	# We might have advanced so much that we're running
	# out of good cards, so throw a bad card into the mix.
	if cardC == null:
		lateGameCards.shuffle()
		for card in lateGameCards:
			var worth : PlayerWorth = player.create_player_worth()
			card.initialize_for_purchase(worth)
			var valid : bool = worth.is_world_possible(card) if card.is_curse() else worth.is_player_possible(lastTwentyCreatures, card)
			if valid:
				if cardA == null:
					cardA = card
				elif cardB == null:
					cardB = card
				elif cardC == null:
					cardC = card
	
	if cardC != null:
		$HUD.spend_points(cardA, cardB, cardC, player)
	else:
		print_debug("Failed to find enough cards")

func _on_mob_timer_timeout():
	var bonusScore = 0
	freeXpCounter += 1
	if freeXpCounter % freeXp == 0:
		bonusScore = 1
		freeXpCounter = 0
		freeXp += 1
	
	var mob : Mob = spawn_mob(mobId, 0, current_path(), bonusScore)
	map.on_mob_spawn(mobId, rng)
	mobId += 1
	
	var mobChildCount = 0 if mob.spawn_children == 0 else mob.spawn_children + 2
	var lastCreatureSummed = [Time.get_unix_time_from_system(), mob.hp, mob.armor, mob.shields.size(), mobChildCount]
	if lastTwentyCreatures.size() >= 20:
		lastTwentyCreatures[ltcWriteIndex] = lastCreatureSummed
		ltcWriteIndex = (ltcWriteIndex + 1) % lastTwentyCreatures.size()
	else:
		lastTwentyCreatures.append(lastCreatureSummed)
		ltcWriteIndex = 0
	
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
	spawns += 1
	#if rollingMobHealthAverage == 0:
	#	rollingMobHealthAverage = mob.hp + mob.armor
	#else:
	#	rollingMobHealthAverage = (rollingMobHealthAverage * 20 + mob.hp + mob.armor) / 21.0
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
	kills += 1
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

func populate_game_stat(grid: GridContainer, attr: String, value : String):
		var attrChild = RichTextLabel.new()
		attrChild.layout_mode = 2
		attrChild.size_flags_horizontal = 3
		attrChild.size_flags_vertical = 3
		attrChild.bbcode_enabled = true
		attrChild.text = str("[right][font_size=22]", attr, "[/font_size][/right]")
		attrChild.fit_content = true
		attrChild.scroll_active = false
		grid.add_child(attrChild)
		var valueChild = RichTextLabel.new()
		valueChild.layout_mode = 2
		valueChild.size_flags_horizontal = 3
		valueChild.size_flags_vertical = 3
		valueChild.bbcode_enabled = true
		valueChild.text = str("[left][font_size=22]", value, "[/font_size][/left]")
		valueChild.fit_content = true
		valueChild.scroll_active = false
		grid.add_child(valueChild)

func populate_game_stats(grid : GridContainer):
	var children = grid.get_children()
	for child in children:
		grid.remove_child(child)
	populate_game_stat(grid, "Map:", map.get_map_name())
	populate_game_stat(grid, "Score:", str(score))
	populate_game_stat(grid, "Hardest Mob:", str(mobId - 1))	
	populate_game_stat(grid, "Spawns:", str(spawns))
	populate_game_stat(grid, "Kills:", str(kills))
