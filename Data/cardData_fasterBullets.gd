extends CardData

var newBulletsPerMinute;

func is_possible(player: Player, cardData: CardData) -> bool:
	return get_multiple(player, cardData) * player.bullet_speed > player.speed
