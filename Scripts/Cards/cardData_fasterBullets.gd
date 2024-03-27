extends CardData

func get_description(player: Player, cardData: CardData) -> String:
	var new_speed : float = player.bullet_speed + get_bullet_speed_we_will_add(player, cardData)
	return str(description, "Bullet speed increase from ", int(round(player.bullet_speed)), " to ", int(round(new_speed)))

func is_possible(player: Player, cardData: CardData) -> bool:
	var new_speed : float = player.bullet_speed + get_bullet_speed_we_will_add(player, cardData)
	return new_speed > player.speed && new_speed <= 1000.0

func apply_card(player: Player):
	player.bullet_speed += get_bullet_speed_we_will_add(player, self)
