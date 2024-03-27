extends CardData

func is_possible(player: Player, _cardData: CardData) -> bool:
	return player.autospend == false
	
func apply_card(player: Player):
	player.autospend = true