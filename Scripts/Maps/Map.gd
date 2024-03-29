extends Node

class_name Map

func start_game(_rng : RandomNumberGenerator):
	print_debug("Map ", self, " did not implement start_game()")

func game_over():
	print_debug("Map ", self, " did not implement game_over()")
	
func current_path() -> Curve2D:
	print_debug("Map ", self, " did not implement current_path()")
	return null

func has_castle() -> bool:
	print_debug("Map ", self, " did not implement has_castle()")
	return false

func get_castle() -> Area2D:
	print_debug("Map ", self, " did not implement get_castle()")
	return null

func request_unique_path(start: Vector2, end: Vector2, pointCount: int, mobId: int, rng: RandomNumberGenerator) -> Curve2D:
	print_debug("Map ", self, " did not implement request_unique_path()")
	return null

func on_mob_spawn(_mob_id : int, _rng : RandomNumberGenerator):
	pass
