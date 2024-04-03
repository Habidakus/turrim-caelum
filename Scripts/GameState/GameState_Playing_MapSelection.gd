extends GameState

var selectedMap : Map = null

func enter_state():
	selectedMap = null
	var mapsNode = %HUD.get_parent().find_child("Maps")
	%HUD.show_map_selection(mapsNode.get_children())

func exit_state():
	%HUD.hide_map_selection()

func on_map_selected():
	if selectedMap != null:
		%GameStateMachine.switch_state("Playing_Action")
		# Note that we don't currently put this call to the start_game() function
		# in the Playing_Action enter() function because that's also called when
		# switching back form picking cards. #TODO: can be better
		%HUD.get_parent().start_game(selectedMap)
