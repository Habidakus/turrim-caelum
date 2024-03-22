extends GameState

func enter_state():
	get_tree().paused = true
	get_parent().get_parent().start_shopping()
	%HUD.show_game_card_selection()

func exit_state():
	%HUD.hide_game_card_selection()

func update(_delta : float):
	if Input.is_action_just_pressed("move_right"):
		%HUD.select_card(1)
	elif Input.is_action_just_pressed("move_left"):
		%HUD.select_card(-1)
	elif Input.is_action_just_pressed("pause"):
		%HUD.select_card(0)
