extends CardData

func is_possible(player: Player, cardData: CardData) -> bool:
	return player.bullet_damage * cardData.get_multiple(player, cardData) < 1.1 * player.get_parent().get_mob_average_health()

func apply_card(player: Player):
	player.bullet_damage *= get_multiple(player, self)
