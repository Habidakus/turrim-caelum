extends Area2D

var target
var rotateSpeed
var travelSpeed = 60.0
var score = 1
var hp = 1
var size = 1.0
var id_for_spawn = 0
var spawn_children = 0
@export var explosion_scene : PackedScene
@onready var animationSprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animationSprite.play()
	animationSprite.speed_scale = rotateSpeed
	self.add_to_group("mob")

func set_target(node : Area2D, rotSpd : float, id : int):
	id_for_spawn = id
	target = node.position;
	rotateSpeed = rotSpd;
	var mutatorA = 0
	while (id != 0) && (id % 3) == 0:
		id = int(id / 3)
		hp += 3
		score += 1
		size *= 1.3333
		travelSpeed *= 0.9
	while (id != 0) && (id % 5) == 0:
		id = int(id / 5)
		travelSpeed *= 2.0
		rotateSpeed *= 2.0
		score += 1
	while (id != 0) && (id != 0) && (id % 2) == 0:
		id = int(id / 2)
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
		get_parent().spawn_mob(id_for_spawn / 13, self.position)
		get_parent().spawn_mob(id_for_spawn / 13, self.position + Vector2(-32, 32))
		get_parent().spawn_mob(id_for_spawn / 13, self.position + Vector2(32, -32))
	
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
	var dir = (target - self.position).normalized()
	self.position += dir * delta * travelSpeed;
	self.rotation_degrees += delta * 25.0 * rotateSpeed
