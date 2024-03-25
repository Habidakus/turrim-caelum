extends GameState

func enter_state():
	get_tree().paused = true
	%HUD.show_game_over()
	%HUD.get_parent().game_over()
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.wait_time = 2
	$Timer.start()
	
	if OS.has_environment("USERNAME"):
		print(OS.get_environment("USERNAME"))

func exit_state():
	%HUD.hide_game_over()
	for mob in get_tree().get_nodes_in_group("mob"):
		mob.queue_free()
	
func _on_timer_timeout():
	$Timer.stop()
	get_parent().switch_state("MainMenu")
