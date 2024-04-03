extends Button

var map : Map = null
var mainNode = null

func set_map(_map : Map, _mainNode):
	map = _map
	mainNode = _mainNode
	text = map.get_map_name()
	connect("pressed", _on_pressed)

func _on_pressed():
	mainNode.set_map(map)
