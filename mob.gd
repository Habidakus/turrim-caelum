extends Area2D

var distance_travelled = 0.0
var target
var rotateSpeed
var travelSpeed = 60.0
var score = 1
var hp = 1
var size = 1.0
var id_for_spawn = 0
var spawn_children = 0
var path : Curve2D = null
@export var explosion_scene : PackedScene
@onready var animationSprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animationSprite.play()
	animationSprite.speed_scale = rotateSpeed
	self.add_to_group("mob")

func set_target(node : Area2D, rotSpd : float, id : int, p: Curve2D, dist):
	id_for_spawn = id
	path = p
	target = node.position;
	distance_travelled = dist
	rotateSpeed = rotSpd;
	var mutatorA = 0
	while (id != 0) && (id % 7) == 0:
		id = int(id / 7)
		hp += 3
		score += 1
		size *= 1.3333
		travelSpeed *= 0.9
	while (id != 0) && (id % 5) == 0:
		id = int(id / 5)
		travelSpeed *= 2.0
		rotateSpeed *= 2.0
		score += 1
	while (id != 0) && (id != 0) && (id % 9) == 0:
		id = int(id / 9)
		spawn_children = 3
		mutatorA = 1
		travelSpeed *= 0.8
		score += 1
	self.scale *= size
	if mutatorA > 0:
		$AnimatedSprite2D.material.set_shader_parameter("mutatorA", mutatorA)
	else:
		$AnimatedSprite2D.material = null

func on_hit():
	if hp > 1:
		hp -= 1
		return
	
	if spawn_children > 0:
		get_parent().spawn_mob(id_for_spawn / 13, distance_travelled - 20.0, path)
		get_parent().spawn_mob(id_for_spawn / 13, distance_travelled - 40.0, path)
		get_parent().spawn_mob(id_for_spawn / 13, distance_travelled - 60.0, path)
	
	# Explode
	var particle = explosion_scene.instantiate()
	particle.position = self.position
	particle.rotation = self.rotation
	particle.get_child(0).emitting = true
	particle.get_child(0).one_shot = true
	particle.get_child(0).lifetime *= size
	particle.get_child(1).pitch_scale *= size
	get_parent().add_child(particle);
	
	# Increase player score
	get_parent().increase_score.emit(score)
	
	# Remove Self
	self.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	distance_travelled += delta * travelSpeed;
	self.position = path.sample_baked(distance_travelled)
	#var dir = (target - self.position).normalized()
	#self.position += dir * delta * travelSpeed;
	self.rotation_degrees += delta * 25.0 * rotateSpeed
