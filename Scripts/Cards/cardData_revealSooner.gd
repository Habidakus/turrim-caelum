extends CardData

var increaseToDetectionRange : float

func does_change_range() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToDetectionRange = get_increase_to_detection_range(worth)
	worth.showPathDist -= increaseToDetectionRange # Increase is actually a subtraction

func get_description(_worth : PlayerWorth) -> String:
	return str(description, "Detection range increased by ", int(round(100.0 * increaseToDetectionRange)), " quatlolubers")

func apply_card(player: Player):
	player.showPathDist -= increaseToDetectionRange # Increase is actually a subtraction
