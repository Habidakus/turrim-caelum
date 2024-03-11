extends Area2D

var target_loc : Vector2
var target_vec : Vector2
var can_kill : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.add_to_group("bullet")
	if $AudioStreamPlayer2D != null:
		$AudioStreamPlayer2D.play()

func init(start_pos : Vector2, target):
	target_loc = target.position
	target_vec = (target_loc - start_pos).normalized()
	rotation = target_vec.angle() + PI / 2.0
	position = start_pos + target_vec * 5.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += target_vec * delta * 100.0

func _on_area_entered(area : Area2D):
	if can_kill == false:
		return
	
	var mobs = get_tree().get_nodes_in_group("mob")
	if area in mobs:
		can_kill = false
		self.queue_free()
		area.on_hit()
