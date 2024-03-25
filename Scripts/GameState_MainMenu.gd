extends GameState

func enter_state():
	get_tree().paused = true
	%HUD.show_main_menu()

func exit_state():
	%HUD.hide_main_menu()

func update(_delta : float):
	if Input.is_action_pressed("move_down"):
		%HUD.ensure_menu_has_focus()
	elif Input.is_action_pressed("move_up"):
		%HUD.ensure_menu_has_focus()
	#elif Input.is_action_pressed("pause"):
		#%HUD.select_menu_button(0)
