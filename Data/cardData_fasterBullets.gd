extends CardData

var newBulletsPerMinute;

func is_possible(player: Player, cardData: CardData) -> bool:
	var new_speed : float = get_multiple(player, cardData) * player.bullet_speed
	return new_speed > player.speed && new_speed <= 1000.0
