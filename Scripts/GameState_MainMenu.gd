extends GameState

func enter_state():
	get_tree().paused = true
	%HUD.show_main_menu()

func exit_state():
	%HUD.hide_main_menu()

func update(_delta : float):
	if Input.is_anything_pressed():
		get_parent().switch_state("Playing_Action")
		get_parent().get_parent().start_game()
