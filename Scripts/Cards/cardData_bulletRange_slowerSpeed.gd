extends CardData

func get_description(player: Player, cardData: CardData) -> String:
	var newSpeed : float = player.bullet_speed - get_bullet_speed_we_will_remove(player, cardData)
	var newRange : float = get_increase_to_bullet_range(player, cardData) + player.bullet_range
	var rangeText : String = str("Bullet range increase from ", int(round(player.bullet_range)), " to ", int(round(newRange)))
	var speedText : String = str("speed reduced from ", int(round(player.bullet_speed)), " to ", int(round(newSpeed)))
	return str(description, rangeText, ", ", speedText)

func is_possible(player: Player, cardData: CardData) -> bool:
	var newRangeOk : bool = get_increase_to_bullet_range(player, cardData) + player.bullet_range <= 1024
	var newSpeed : float = player.bullet_speed + get_bullet_speed_we_will_add(player, cardData)
	var newSpeedOk = newSpeed > player.speed && newSpeed <= 1000.0
	return newRangeOk && newSpeedOk

func apply_card(player: Player):
	player.bullet_range *= get_multiple(player, self)
	player.bullet_speed -= get_bullet_speed_we_will_remove(player, self)
