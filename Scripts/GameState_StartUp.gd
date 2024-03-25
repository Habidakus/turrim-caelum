extends GameState
	
func enter_state():
	get_tree().paused = true
	%HUD.show_title()
	$TitleTimer.timeout.connect(_on_title_timer_timeout)
	$TitleTimer.wait_time = 2
	$TitleTimer.start()
	%HUD.get_parent().load_highscore()

func exit_state():
	%HUD.hide_title()

func _on_title_timer_timeout():
	$TitleTimer.stop()
	get_parent().switch_state("MainMenu")
