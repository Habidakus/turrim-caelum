extends GameState

var timerExpired : bool = false

func _ready():
	$Timer.timeout.connect(_on_timer_timeout)
	$Timer.wait_time = 2

func enter_state():
	get_tree().paused = true
	timerExpired = false
	%HUD.show_game_over(false)
	%HUD.get_parent().game_over()
	$Timer.start()

func exit_state():
	%HUD.hide_game_over()

func update(_delta):
	if timerExpired == true && Input.is_anything_pressed():
		%GameStateMachine.switch_state("MainMenu")

func _on_timer_timeout():
	$Timer.stop()
	timerExpired = true
	%HUD.show_game_over(true)
	for mob in get_tree().get_nodes_in_group("mob"):
		mob.queue_free()
