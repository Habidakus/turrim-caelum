extends Area2D

var distance_travelled = 0.0
var target
var rotateSpeed
var travelSpeed = 33.0
var score = 1
var hp = 10
var armor = 0
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
	process_mode = Node.PROCESS_MODE_PAUSABLE
	self.add_to_group("mob")

func set_target(node : Area2D, rotSpd : float, id : int, p: Curve2D, dist):
	id_for_spawn = id
	var id_for_hp = id
	path = p
	target = node.position;
	distance_travelled = dist
	rotateSpeed = rotSpd;
	var mutatorA = 0
	# ELEVEN - armored
	while (id != 0) && (id % 2) == 0:
		id = int(id / 2)
		armor += 1
		travelSpeed *= 0.95
	# SEVEN - super sized
	while (id != 0) && (id % 7) == 0:
		id = int(id / 7)
		hp += 30
		score += 1
		size *= 1.3333
		travelSpeed *= 0.9
	# FIVE - speedy
	while (id != 0) && (id % 5) == 0:
		id = int(id / 5)
		travelSpeed *= 2.0
		rotateSpeed *= 2.0
		score += 1
	# THREE - children
	while (id != 0) && (id % 3) == 0:
		id = int(id / 3)
		id_for_spawn = int(id_for_spawn / 3)
		spawn_children += 1
		mutatorA = 1
		travelSpeed *= 0.8
		score += 1
	while (id_for_hp > 31):
		id_for_hp -= 31
		hp *= 1.1
	self.scale *= size
	if mutatorA > 0:
		$AnimatedSprite2D.material.set_shader_parameter("mutatorA", mutatorA)
	else:
		$AnimatedSprite2D.material = null

func on_hit(damage : float):
	damage -= armor
	if damage <= 0:
		# TODO: Play *plink* sound
		return
		
	if hp > damage:
		hp -= damage
		get_parent().play_impact_sound()
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.1).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self, "scale", Vector2(size, size), 0.1).set_trans(Tween.TRANS_BOUNCE)
		return
	
	var offset = distance_travelled - 20.0
	if spawn_children > 0:
		spawn_children += 2
	while spawn_children > 0:
		spawn_children -= 1
		get_parent().spawn_mob(id_for_spawn, offset, path)
		offset -= 30.0
	
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
