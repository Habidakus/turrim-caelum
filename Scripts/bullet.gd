extends Area2D

var target_loc : Vector2
var target_vec : Vector2
var can_kill : bool = true
var damage : float = 1
var lifespan : float
var speed : float = 100

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("bullet")
	process_mode = Node.PROCESS_MODE_PAUSABLE
	if $AudioStreamPlayer2D != null:
		$AudioStreamPlayer2D.play()

func init(start_pos : Vector2, _lifespan: float, _speed : float, target, _damage : float):
	target_loc = target.position
	target_vec = (target_loc - start_pos).normalized()
	rotation = target_vec.angle() + PI / 2.0
	position = start_pos + target_vec * 5.0
	lifespan = _lifespan
	damage = _damage
	speed = _speed

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += target_vec * delta * speed
	lifespan -= delta
	if lifespan <= 0:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.RED, 0.2)
		tween.tween_callback(self.queue_free)

func _on_area_entered(area : Area2D):
	if can_kill == false:
		return
	
	var mobs = get_tree().get_nodes_in_group("mob")
	if area in mobs:
		can_kill = false
		self.queue_free()
		area.on_hit(damage)
