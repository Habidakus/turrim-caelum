extends CardData

func get_description(player: Player, cardData: CardData) -> String:
	var newSpeed : float = cardData.get_multiple(player, cardData) * player.speed
	return str(description, "Player speed increase from ", int(round(player.speed)), " to ", int(round(newSpeed)))
	
func is_possible(player: Player, cardData: CardData) -> bool:
	var newSpeed : float = cardData.get_multiple(player, cardData) * player.speed
	return newSpeed < player.bullet_speed && newSpeed <= 800.0

func apply_card(player: Player):
	player.speed *= get_multiple(player, self)
