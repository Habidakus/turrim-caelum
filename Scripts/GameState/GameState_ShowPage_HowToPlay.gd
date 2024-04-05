extends GameState

var mustReleaseFirst : bool

func enter_state():
	get_tree().paused = true
	%HUD.show_page_how_to_play()
	mustReleaseFirst = Input.is_action_pressed("pause")

func exit_state():
	%HUD.hide_page_how_to_play()
	
func update(_delta):
	if mustReleaseFirst:
		if Input.is_action_just_released("pause"):
			mustReleaseFirst = false
		return
	if Input.is_anything_pressed():
		%GameStateMachine.switch_state("MainMenu")
