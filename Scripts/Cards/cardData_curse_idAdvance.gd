extends CardData

var multiple : float = 1

func is_curse() -> bool:
	return true;

func initialize_for_purchase(_player: Player, cardData: CardData):
	multiple = cardData.boonMultiple
	
func is_possible(_player: Player, _cardData: CardData) -> bool:
	return true
	
func apply_card(player: Player):
	player.get_parent().advance_id(multiple)
