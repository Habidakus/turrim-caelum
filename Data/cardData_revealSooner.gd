extends CardData

func is_possible(player: Player, cardData: CardData) -> bool:
	return player.showPathDist / cardData.get_multiple(player, cardData) >= 0.5

func apply_card(player: Player):
	player.showPathDist /= get_multiple(player, self)
