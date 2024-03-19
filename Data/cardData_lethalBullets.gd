extends CardData

func is_possible(player: Player, cardData: CardData) -> bool:
	return player.bullet_damage * cardData.get_multiple(player, cardData) < 1.1 * player.get_parent().get_mob_average_health()
