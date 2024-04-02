extends CardData

var increaseToPlayerSpeed : float
var decreaseToDetectionRange : float

func initialize_for_purchase(worth : PlayerWorth):
	increaseToPlayerSpeed = get_increase_to_player_speed(worth)
	worth.shipSpeed += increaseToPlayerSpeed
	decreaseToDetectionRange = get_decrease_to_detection_range(worth)
	worth.showPathDist += decreaseToDetectionRange # Decrease is actually an addition

func get_description(worth : PlayerWorth) -> String:
	var newSpeed : float = increaseToPlayerSpeed + worth.shipSpeed
	var speedText : String = str("Player speed increase from ", int(round(worth.shipSpeed)), " to ", int(round(newSpeed)))
	var radarText : String = str("detection range decreased by ", int(round(100.0 * decreaseToDetectionRange)), " quatlolubers")
	return str(description, speedText, ", ", radarText)

func apply_card(player: Player):
	player.speed += increaseToPlayerSpeed
	player.showPathDist += decreaseToDetectionRange # Decrease is actually an addition
