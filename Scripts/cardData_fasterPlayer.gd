extends CardData

func is_possible(player: Player, cardData: CardData) -> bool:
	var new_speed : float = cardData.get_multiple(player, cardData) * player.speed
	return new_speed < player.bullet_speed && new_speed <= 800.0

func apply_card(player: Player):
	player.speed *= get_multiple(player, self)
