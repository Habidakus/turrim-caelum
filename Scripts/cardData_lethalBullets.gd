extends CardData

func amount_we_will_add(player: Player, cardData: CardData) -> float:
	var multiple = cardData.get_multiple(player, cardData)
	var straight_add = 10.0 * multiple * multiple
	var scale_existing = player.bullet_damage * (sqrt(multiple) - 1.0)
	return max(straight_add, scale_existing)
	#return player.bullet_damage * (cardData.get_multiple(player, cardData) - 1.0)

func is_possible(player: Player, cardData: CardData) -> bool:
	return player.bullet_damage + amount_we_will_add(player, cardData) < 1.1 * player.get_parent().get_mob_average_health()

func apply_card(player: Player):
	player.bullet_damage += amount_we_will_add(player, self)
