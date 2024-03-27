extends CardData

func get_description(player: Player, cardData: CardData) -> String:
	var newRange : float = get_increase_to_bullet_range(player, cardData) + player.bullet_range
	return str(description, "Bullet range increase from ", int(round(player.bullet_range)), " to ", int(round(newRange)))

func is_possible(player: Player, cardData: CardData) -> bool:
	var newRange : float = get_increase_to_bullet_range(player, cardData) + player.bullet_range
	return newRange <= 1024

func apply_card(player: Player):
	player.bullet_range *= get_multiple(player, self)
