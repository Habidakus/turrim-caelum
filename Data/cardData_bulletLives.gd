extends CardData

var newBulletsPerMinute;

func is_possible(player: Player, cardData: CardData) -> bool:
	var new_lifespan : float = get_multiple(player, cardData) * player.bullet_lifespan
	return new_lifespan <= 7

func apply_card(player: Player):
	player.bullet_lifespan *= get_multiple(player, self)
