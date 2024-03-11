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
	
	$MobTimer.start()
	$HUD.set_score(0)

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
	var start_index = rng.randi_range(- screen_size.x, screen_size.y)
	if start_index < 0:
		spawn_mob(mobId, Vector2(0 - start_index, 0))
	else:
		spawn_mob(mobId, Vector2(0, start_index))
	mobId += 1
		
func spawn_mob(id, pos):
	var mob = mob_scene.instantiate()
	mob.position = Vector2(clamp(pos.x, 8, screen_size.x - 8), clamp(pos.y, 8, screen_size.y - 8))
	var speed_scale = rng.randf_range(0.8, 1.2)
	mob.set_target($Castle, speed_scale, id)
	call_deferred("add_child", mob)
	#add_child(mob)

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
