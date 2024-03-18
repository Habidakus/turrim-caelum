extends CardData

func is_possible(player: Player, cardData: CardData) -> bool:
	return cardData.get_multiple(player, cardData) * player.speed < player.bullet_speed
