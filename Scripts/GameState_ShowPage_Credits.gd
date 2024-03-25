extends GameState

func enter_state():
	get_tree().paused = true
	%HUD.show_page_credits()

func exit_state():
	%HUD.hide_page_credits()
	
func update(_delta):
	if Input.is_anything_pressed():
		%GameStateMachine.switch_state("MainMenu")
