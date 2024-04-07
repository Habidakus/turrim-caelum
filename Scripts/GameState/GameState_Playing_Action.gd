extends GameState

var main
func enter_state():
	main = %GameStateMachine.get_parent()
	main.set_pause_state(false)
	%HUD.show_game_action()

func exit_state():
	main.set_pause_state(true)
	%HUD.hide_game_action()

func update(_delta):
	if main.player_can_spend_money():
		if Input.is_action_just_pressed("pause") || main.player_bought_autospend():
			%GameStateMachine.switch_state("Playing_CardSelection")
