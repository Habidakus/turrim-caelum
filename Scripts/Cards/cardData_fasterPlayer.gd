extends CardData

var increaseToPlayerSpeed : float

func does_change_player_or_bullet_speed() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	increaseToPlayerSpeed = get_increase_to_player_speed(worth)
	worth.shipSpeed += increaseToPlayerSpeed

func get_description(worth : PlayerWorth) -> String:
	var newSpeed : float = increaseToPlayerSpeed + worth.shipSpeed
	return str(description, "Player speed increase from ", int(round(worth.shipSpeed)), " to ", int(round(newSpeed)))

func apply_card(player: Player):
	player.speed += increaseToPlayerSpeed
