extends CardData

var newBulletsPerMinute;

func is_possible(player: Player, cardData: CardData) -> bool:
	var newRange : float = get_multiple(player, cardData) * player.bullet_range
	return newRange <= 1024

func apply_card(player: Player):
	player.bullet_range *= get_multiple(player, self)
