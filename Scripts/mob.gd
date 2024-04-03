extends Area2D

class_name Mob

var regrowShieldTimer : float = -1.0
var distance_travelled = 0.0
var childOffset_regressDist = -1.0
var childOffset_regressPoint = Vector2.ZERO
var childOffset_regressTime = -1.0
var show_path_dist = 1.0
var final_target : Node2D = null
var rotateSpeed
var travelSpeed_low = 30.0
var travelSpeed = travelSpeed_low
var travelSpeed_high = 120.0
var score = 1
var hp : float = 18
var armor : float = 0
var size = 1.0
var shields = []
var id_for_spawn = 0
var spawn_children : int = 0
var path : Curve2D = null
var pathLength;
var pathParticles : Array = []
var alternate1EnemyFrames = load("res://Graphics/EnemyBSpriteFrames.tres")
var alternate2EnemyFrames = load("res://Graphics/EnemyCSpriteFrames.tres")
var shieldScene : PackedScene = load("res://Scenes/Shield.tscn")
@export var explosion_scene : PackedScene
@export var path_particle_scene : PackedScene
@onready var animationSprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	animationSprite.play()
	animationSprite.speed_scale = rotateSpeed
	process_mode = Node.PROCESS_MODE_PAUSABLE
	self.add_to_group("mob")

func set_target(target : Node2D, rotSpd : float, id : int, p: Curve2D, dist, pathGenerator : Map, player : Player, bonusScore, rng : RandomNumberGenerator):
	id_for_spawn = id
	travelSpeed = lerp(travelSpeed_low, travelSpeed_high, float(id - 50) / 500.0)
	var id_for_hp = id
	var id_for_map = id
	var swerve : int = 0
	var potentialShield : int = 0
	score += (bonusScore * 2)
	show_path_dist = player.showPathDist
	final_target = target;
	distance_travelled = dist
	rotateSpeed = rotSpd;
	var mutatorA = 0
	# SEVENTEEN - tiny
	while (id != 0) && (id % 17) == 0:
		id = int(id / 17)
		size *= 0.666
		travelSpeed *= 1.1
		score += 1
		hp -= 5
		armor += 5
	# THIRTEEN - swerve
	while (id != 0) && (id % 13) == 0:
		id = int(id / 13)
		id_for_spawn = int(id_for_spawn / 13)
		swerve += 1
		if rotateSpeed > 0:
			rotateSpeed *= -1.0
		rotateSpeed *= 1.25
		show_path_dist *= 0.75
	# ELEVEN - potential shield
	while (id != 0) && (id % 11) == 0:
		id = int(id / 11)
		potentialShield += 3
		travelSpeed *= 0.925
		score += 1
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
		travelSpeed *= 1.8
		rotateSpeed *= 1.5
	# THREE - children
	while (id != 0) && (id % 3) == 0:
		id = int(id / 3)
		id_for_spawn = int(id_for_spawn / 3)
		spawn_children += 1
		mutatorA = 1
		travelSpeed *= 0.8
	# TWO - armored
	while (id != 0) && (id % 2) == 0:
		id = int(id / 2)
		armor += 1
		travelSpeed *= 0.95
	if id_for_hp >= 41:
		hp *= pow(1.1, int(id_for_hp / 41))
	if swerve > 0 && pathGenerator != null:
		path = pathGenerator.request_unique_path(p.get_point_position(0), p.get_point_position(p.point_count - 1), 3 * swerve, id_for_map, rng)
	else:
		path = p
	pathLength = path.get_baked_length()
	self.scale *= size
	if armor > 0:
		if size > 1.16:
			$AnimatedSprite2D.sprite_frames = alternate2EnemyFrames
		else:
			$AnimatedSprite2D.sprite_frames = alternate1EnemyFrames
	if mutatorA > 0:
		$AnimatedSprite2D.material.set_shader_parameter("mutatorA", mutatorA)
	else:
		$AnimatedSprite2D.material = null
	var shieldScale : Vector2 = 1.5 * self.scale
	while potentialShield > 0:
		potentialShield -= 1
		var shield = shieldScene.instantiate()
		shield.scale *= shieldScale
		shields.append([shieldScale, shield])
		shieldScale *= 1.2
		add_child(shield)

func play_impact_sound():
	if armor > 0:
		$ArmorTing.play()
	else:
		$ImpactPlayer.play()

func on_hit(damage : float):
	for shieldIndex in shields.size():
		var reverseIndex = shields.size() - (1 + shieldIndex)
		if shields[reverseIndex][1] != null:
			$ShieldPop.play()
			regrowShieldTimer = 2.0
			shields[reverseIndex][1].queue_free()
			shields[reverseIndex][1] = null
			return
			
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
	
	var regressDist = distance_travelled - 20.0
	var time = 0.3333
	if spawn_children > 0:
		spawn_children += 2
	while spawn_children > 0:
		spawn_children -= 1
		var childMob : Mob = get_parent().spawn_mob(id_for_spawn, distance_travelled, path, final_target, 0)
		if regressDist < pathLength:
			childMob.set_child_path(self, regressDist, time)
		else:
			var regressionVector : Vector2 = (self.position - final_target.position).normalized() * (distance_travelled - regressDist);
			childMob.set_child_vector(self, self.position + regressionVector, time)
		regressDist -= 30.0
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

# If this mob is a child of a just destroyed parent, set their child regression point
func set_child_path(parent: Mob, regressDist: float, regressTime: float):
	assert(regressDist < pathLength)
	travelSpeed = parent.travelSpeed
	position = parent.position
	rotation = parent.rotation
	childOffset_regressTime = regressTime
	childOffset_regressDist = max(0.0, regressDist)
	childOffset_regressPoint = Vector2.ZERO

# If this mob is a child of a just destroyed parent, set their child regression point
func set_child_vector(parent: Mob, regressPoint: Vector2, regressTime: float):
	travelSpeed = parent.travelSpeed
	position = parent.position
	rotation = parent.rotation
	childOffset_regressTime = regressTime
	childOffset_regressPoint = regressPoint
	childOffset_regressDist = -1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if childOffset_regressTime > 0 && childOffset_regressTime < delta:
		# The impact has finally warn off, set the child to their regress point
		if childOffset_regressDist >= 0.0:
			self.position = path.sample_baked(childOffset_regressDist)
			distance_travelled = childOffset_regressDist
		else:
			self.position = childOffset_regressPoint
		childOffset_regressTime = 0
		childOffset_regressPoint = Vector2.ZERO
		childOffset_regressDist = -1
	elif childOffset_regressTime > 0:
		# Child is still travelling backwards after mother was blown up
		var diffPerSec : float = delta / childOffset_regressTime
		childOffset_regressTime -= delta
		if childOffset_regressDist >= 0.0:
			distance_travelled = lerp(distance_travelled, childOffset_regressDist, sqrt(diffPerSec))
			self.position = path.sample_baked(distance_travelled)
		else:
			self.position = Vector2(lerp(self.position.x, childOffset_regressPoint.x, sqrt(diffPerSec)), lerp(self.position.y, childOffset_regressPoint.y, sqrt(diffPerSec)))
			self.position = lerp(self.position, childOffset_regressPoint, sqrt(diffPerSec))
	elif distance_travelled < pathLength:
		# Mob is travelling along the pre-defined path
		distance_travelled += delta * travelSpeed
		self.position = path.sample_baked(distance_travelled)
	else:
		# Mob has travelled past the end of the path, and should zero in on the final target
		distance_travelled += delta * travelSpeed
		var dir : Vector2 = (final_target.position - self.position).normalized()
		self.position += dir * travelSpeed * delta

	if regrowShieldTimer > 0.0:
		regrowShieldTimer -= delta
		if regrowShieldTimer <= 0.0:
			var shieldToRegrow : int = -1
			for shieldIndex in shields.size():
				if shields[shieldIndex][1] == null:
					shieldToRegrow = shieldIndex
					break
			if shieldToRegrow != -1:
				var shield = shieldScene.instantiate()
				shield.scale *= shields[shieldToRegrow][0]
				shields[shieldToRegrow][1] = shield
				add_child(shield)
				regrowShieldTimer = 0.75

	var hue = 0
	var frac : float = distance_travelled / pathLength
	if frac > 1:
		frac = 1
		hue = 1
	var close : float = frac - show_path_dist
	var spin : float = 25.0
	if close > 0.05:
		var amount = close / 0.05
		if int(amount) - 1 > pathParticles.size():
			var particle = path_particle_scene.instantiate()
			particle.amount = min(500, 25 * amount)
			var r = lerp(particle.color.r, Color.RED.r, hue) 
			var b = lerp(particle.color.b, Color.RED.b, hue) 
			var g = lerp(particle.color.g, Color.RED.g, hue)
			particle.color.r = r
			particle.color.b = b
			particle.color.g = g
			pathParticles.append(particle)
			add_child(particle)
		spin *= lerp(1, 5, close / (1.0 - show_path_dist))
	self.rotation_degrees += delta * spin * rotateSpeed
