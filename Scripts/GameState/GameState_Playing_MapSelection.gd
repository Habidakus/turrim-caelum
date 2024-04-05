extends GameState

var selectedMap : Map = null
var mustReleaseFirst : bool

func enter_state():
	selectedMap = null
	mustReleaseFirst = Input.is_action_pressed("pause")
	var mapsNode = %HUD.get_parent().find_child("Maps")
	%HUD.show_map_selection(mapsNode.get_children())

func exit_state():
	%HUD.hide_map_selection()

func update(_delta : float):
	if Input.is_action_pressed("move_down") ||  Input.is_action_pressed("move_up"):
		%HUD.ensure_map_selection_has_focus()
	if mustReleaseFirst:
		if Input.is_action_just_released("pause"):
			mustReleaseFirst = false
		return
	if Input.is_action_just_pressed("pause"):
		%HUD.activate_map_selection_with_focus()

func on_map_selected():
	if selectedMap != null:
		%GameStateMachine.switch_state("Playing_Action")
		# Note that we don't currently put this call to the start_game() function
		# in the Playing_Action enter() function because that's also called when
		# switching back form picking cards. #TODO: can be better
		%HUD.get_parent().start_game(selectedMap)
