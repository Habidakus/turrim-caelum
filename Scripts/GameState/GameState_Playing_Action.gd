extends GameState

var main
func enter_state():
	get_tree().paused = false
	main = %GameStateMachine.get_parent()
	%HUD.show_game_action()

func exit_state():
	%HUD.hide_game_action()

func update(_delta):
	if main.player_can_spend_money():
		if Input.is_action_just_pressed("pause") || main.player_bought_autospend():
			%GameStateMachine.switch_state("Playing_CardSelection")
