extends Area2D

@export var explosion_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _on_area_entered(area):
	if area in get_tree().get_nodes_in_group("mob"):
		area.on_hit(100)
	
	# Explode
	var particle = explosion_scene.instantiate()
	particle.position = self.position
	particle.rotation = self.rotation
	particle.get_child(0).emitting = true
	particle.get_child(0).one_shot = true
	get_parent().add_child(particle);
	get_parent().find_child("GameStateMachine").switch_state("Playing_GameOver")
	self.queue_free()
