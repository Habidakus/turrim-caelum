extends CardData

var increaseToPlayerSpeed : float

func initialize_for_purchase(worth : PlayerWorth):
	increaseToPlayerSpeed = worth.shipSpeed * (boonMultiple - 1.0)
	worth.shipSpeed += increaseToPlayerSpeed

func get_description(worth : PlayerWorth) -> String:
	var newSpeed : float = increaseToPlayerSpeed + worth.shipSpeed
	return str(description, "Player speed increase from ", int(round(worth.shipSpeed)), " to ", int(round(newSpeed)))

func apply_card(player: Player):
	player.speed += increaseToPlayerSpeed
