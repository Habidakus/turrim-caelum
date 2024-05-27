extends Area2D

class_name Player

@export var speed = 150
@export var bullet_scene: PackedScene = null
@export var explosion_scene : PackedScene
var screen_size;
var showPathDist : float = 0.7;
var bulletsPerSecond : float = 1.0 / 0.7;
var bullet_range : float = 275.0;
var bullet_speed : float = 215.0;
var bullet_damage : float = 9.0;
var next_shot
var smartWeaponUnlock : int = 90;
var autospend : bool = false;
var tchotchke : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	next_shot = 1.0 / bulletsPerSecond
	process_mode = Node.PROCESS_MODE_PAUSABLE

func get_screen_size():
	return screen_size

func create_player_worth() -> PlayerWorth:
	var worth : PlayerWorth = PlayerWorth.new()
	worth.shipSpeed = speed
	worth.bulletsPerSecond = bulletsPerSecond
	worth.bulletRange = bullet_range
	worth.bulletSpeed = bullet_speed
	worth.bulletDamage = bullet_damage
	worth.autospendCount = 1 if autospend else 0
	worth.tchotchkeCount = 1 if tchotchke else 0
	worth.showPathDist = showPathDist
	worth.smartWeaponCount = 0 if smartWeaponUnlock < get_parent().mobId else 1
	worth.timeDilation = get_parent().timeDilation
	return worth

func activate_smart_weapon(castleBased : bool):
	smartWeaponUnlock = get_parent().activate_smart_weapon(castleBased)

func activate_smart_weapon_regression(regressDist: float):
	smartWeaponUnlock = get_parent().activate_smart_weapon_regression(regressDist)

#func _draw():
	#draw_line(Vector2.ZERO, to_local(draw_target), Color.RED, 5, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var timeDilation : float = get_parent().timeDilation
	next_shot -= delta * timeDilation
	
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta * timeDilation
	position = position.clamp(Vector2(20,20), screen_size - Vector2(20,20))
	
	var maxDist = -1
	var closestMob = null
	var array_of_mobs = get_tree().get_nodes_in_group("mob")
	if !array_of_mobs.is_empty():
		for mob in array_of_mobs:
			var square = mob.position.distance_squared_to(self.position)
			if maxDist < 0 || maxDist > square:
				maxDist = square
				closestMob = mob
	
	if closestMob != null:
		rotation = (closestMob.position - self.position).angle() + PI / 2.0
		if next_shot <= 0:
				next_shot = 1.0 / bulletsPerSecond
				var bullet = bullet_scene.instantiate()
				var lifespan = bullet_range / bullet_speed;
				bullet.init(self.position, lifespan, bullet_speed, closestMob, bullet_damage)
				self.get_parent().add_child(bullet)

func _on_area_entered(area : Area2D):
	var hitMob : bool = area.is_in_group("mob")
	if hitMob || area.is_in_group("rock"):
		if hitMob:
			area.on_hit(100)
		
		# Explode
		var particle = explosion_scene.instantiate()
		particle.position = self.position
		particle.rotation = self.rotation
		particle.get_child(0).emitting = true
		particle.get_child(0).one_shot = true
		get_parent().add_child(particle)
		
		var gsm = get_parent().find_child("GameStateMachine")
		if gsm != null:
			gsm.switch_state("Playing_GameOver")
		else:
			print_debug("Game State Machine not found")
