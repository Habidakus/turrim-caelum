extends Area2D

class_name Mob

var distance_travelled = 0.0
var childOffset_distance = -1.0
var childOffset_time = -1.0
var show_path_dist = 1.0
var target
var rotateSpeed
var travelSpeed = 33.0
var score = 1
var hp : float = 20
var armor : float = 0
var size = 1.0
var id_for_spawn = 0
var spawn_children = 0
var path : Curve2D = null
var pathLength;
var pathParticles : Array = []
@export var explosion_scene : PackedScene
@export var path_particle_scene : PackedScene
@onready var animationSprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animationSprite.play()
	animationSprite.speed_scale = rotateSpeed
	process_mode = Node.PROCESS_MODE_PAUSABLE
	self.add_to_group("mob")

func set_target(node : Area2D, rotSpd : float, id : int, p: Curve2D, dist, pathGenerator):
	id_for_spawn = id
	var id_for_hp = id
	var swerve : int = 0
	show_path_dist = pathGenerator.get_show_path_dist()
	target = node.position;
	distance_travelled = dist
	rotateSpeed = rotSpd;
	var mutatorA = 0
	# THIRTEEN - swerve
	while (id != 0) && (id % 13) == 0:
		id = int(id / 13)
		id_for_spawn = int(id_for_spawn / 13)
		swerve += 1
		if rotateSpeed > 0:
			rotateSpeed *= -1.0
		rotateSpeed *= 1.25
		show_path_dist *= 0.75
	while (id != 0) && (id % 17) == 0:
		id = int(id / 17)
		size *= 0.666
		score += 1
		armor += 5
	# ELEVEN - armored
	while (id != 0) && (id % 2) == 0:
		id = int(id / 2)
		armor += 1
		travelSpeed *= 0.95
	# SEVEN - super sized
	while (id != 0) && (id % 7) == 0:
		id = int(id / 7)
		hp += 65
		score += 1
		size *= 1.3333
		travelSpeed *= 0.9
	# FIVE - speedy
	while (id != 0) && (id % 5) == 0:
		id = int(id / 5)
		travelSpeed *= 2.0
		rotateSpeed *= 1.5
	# THREE - children
	while (id != 0) && (id % 3) == 0:
		id = int(id / 3)
		id_for_spawn = int(id_for_spawn / 3)
		spawn_children += 1
		mutatorA = 1
		travelSpeed *= 0.8
	if id_for_hp >= 37:
		hp *= pow(1.1, int(id_for_hp / 37))
	if swerve > 0 && pathGenerator != null:
		path = pathGenerator.request_unique_path(p.get_point_position(0), p.get_point_position(p.point_count - 1), 3 * swerve)
	else:
		path = p
	pathLength = path.get_baked_length()
	self.scale *= size
	if mutatorA > 0:
		$AnimatedSprite2D.material.set_shader_parameter("mutatorA", mutatorA)
	else:
		$AnimatedSprite2D.material = null

func play_impact_sound():
	if armor > 0:
		$ArmorTing.play()
	else:
		$ImpactPlayer.play()

func on_hit(damage : float):
	damage -= armor
	if damage <= 0:
		# TODO: Play *plink* sound
		return
		
	if hp > damage:
		hp -= damage
		play_impact_sound()
		var tween = get_tree().create_tween()
		tween.tween_property(self, "scale", Vector2(0.5, 0.5), 0.1).set_trans(Tween.TRANS_BOUNCE)
		tween.tween_property(self, "scale", Vector2(size, size), 0.1).set_trans(Tween.TRANS_BOUNCE)
		distance_travelled -= 3.0
		return
	
	var offset = distance_travelled - 20.0
	var time = 0.3333
	if spawn_children > 0:
		spawn_children += 2
	while spawn_children > 0:
		spawn_children -= 1
		var childMob : Mob = get_parent().spawn_mob(id_for_spawn, distance_travelled, path)
		childMob.travelSpeed = self.travelSpeed
		childMob.childOffset_distance = offset
		childMob.childOffset_time = time
		offset -= 30.0
		time += 0.3333
	
	# Explode
	var particle = explosion_scene.instantiate()
	particle.position = self.position
	particle.rotation = self.rotation
	particle.get_child(0).emitting = true
	particle.get_child(0).one_shot = true
	particle.get_child(0).lifetime *= size
	particle.get_child(1).pitch_scale /= size
	particle.get_child(1).volume_db -= 20
	get_parent().add_child(particle);
	
	# Increase player score
	get_parent().increase_score.emit(score)
	
	# Remove Self
	self.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if childOffset_time > 0:
		var diffPerSec : float = delta / childOffset_time
		childOffset_time -= delta
		distance_travelled = lerp(distance_travelled, childOffset_distance, sqrt(diffPerSec))
	else:
		distance_travelled += delta * travelSpeed
	
	self.position = path.sample_baked(distance_travelled)
	
	var close : float = (distance_travelled / pathLength) - show_path_dist
	var spin : float = 25.0
	if close > 0.05:
		var amount = close / 0.05
		if int(amount) - 1 > pathParticles.size():
			var particle = path_particle_scene.instantiate()
			particle.amount = 50 * amount
			if close > 0.15:
				var hue = (close - 0.15) / 0.15
				if hue > 1:
					hue = 1
				var r = lerp(particle.color.r, Color.RED.r, hue) 
				var b = lerp(particle.color.b, Color.RED.b, hue) 
				var g = lerp(particle.color.g, Color.RED.g, hue)
				particle.color.r = r
				particle.color.b = b
				particle.color.g = g
			pathParticles.append(particle)
			add_child(particle)
		spin *= lerp(1, 10, close / (1.0 - show_path_dist))
	self.rotation_degrees += delta * spin * rotateSpeed
