extends Area2D

class_name Player

@export var speed = 150
@export var bullet_scene: PackedScene = null
@export var explosion_scene : PackedScene
var screen_size;
var showPathDist : float = 0.7;
var rate_of_fire : float = 0.75;
var bullet_range : float = 250.0;
var bullet_speed : float = 200.0;
var bullet_damage : float = 8.0;
var next_shot
var autospend : bool = false;

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	next_shot = rate_of_fire
	process_mode = Node.PROCESS_MODE_PAUSABLE

func get_screen_size():
	return screen_size
	
#func _draw():
	#draw_line(Vector2.ZERO, to_local(draw_target), Color.RED, 5, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	next_shot -= delta;
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
	
	position += velocity * delta
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
				next_shot = rate_of_fire
				var bullet = bullet_scene.instantiate()
				var lifespan = bullet_range / bullet_speed;
				bullet.init(self.position, lifespan, bullet_speed, closestMob, bullet_damage)
				self.get_parent().add_child(bullet)

func _on_area_entered(area):
	if area in get_tree().get_nodes_in_group("mob"):
		area.on_hit(100)
		
		# Explode
		var particle = explosion_scene.instantiate()
		particle.position = self.position
		particle.rotation = self.rotation
		particle.get_child(0).emitting = true
		particle.get_child(0).one_shot = true
		get_parent().add_child(particle)
		get_parent().game_over()
