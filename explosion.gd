extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	var timer = get_tree().create_timer(1.0)
	timer.connect("timeout", kill_self)
	var audio = get_parent().find_child("AudioStreamPlayer2D")
	if audio != null:
		audio.play()

func kill_self():
	queue_free()
