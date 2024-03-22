
extends Node

var states : Dictionary = {}
var current_state : GameState = null

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	for child in get_children():
		if child is GameState:
			states[child.name.to_lower()] = child
	switch_state("StartUp")

func _process(_delta):
	if current_state != null:
		current_state.update(_delta)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func switch_state(state_name: String):
	if current_state != null:
		current_state.exit_state()
	
	current_state = states.get(state_name.to_lower())
	if current_state != null:
		current_state.enter_state()
	else:
		print_debug("FAILED TO FIND STATE: ", state_name)
