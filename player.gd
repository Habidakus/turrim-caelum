extends Area2D

@export var speed = 200
@export var bullet_scene: PackedScene = null
@export var explosion_scene : PackedScene
var screen_size;
var rate_of_fire = 1;
var next_shot

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
	position = position.clamp(Vector2.ZERO, screen_size)
	
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
				bullet.init(self.position, closestMob)
				self.get_parent().add_child(bullet)


func _on_area_entered(area):
	if area in get_tree().get_nodes_in_group("mob"):
		area.on_hit()
		
		# Explode
		var particle = explosion_scene.instantiate()
		particle.position = self.position
		particle.rotation = self.rotation
		particle.get_child(0).emitting = true
		particle.get_child(0).one_shot = true
		get_parent().add_child(particle)
		get_parent().game_over()
