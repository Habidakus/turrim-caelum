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
	# TODO: This is rediculous, either use a signal, or find a better way to find Main
	var main = get_parent().get_parent().get_parent()
	main.add_child(particle);
	var gsm = main.find_child("GameStateMachine")
	if gsm != null:
		gsm.switch_state("Playing_GameOver")
	else:
		print_debug("Game State Machine not found under ", main)
	self.queue_free()
