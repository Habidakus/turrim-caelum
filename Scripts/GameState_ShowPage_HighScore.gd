extends GameState

func enter_state():
	get_tree().paused = true
	%HUD.get_parent().populate_high_score()
	%HUD.show_high_score()

func exit_state():
	%HUD.hide_high_score()
	
func update(_delta):
	if Input.is_anything_pressed():
		%GameStateMachine.switch_state("MainMenu")
