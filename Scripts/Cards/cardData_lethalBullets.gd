extends CardData

func get_description(player: Player, cardData: CardData) -> String:
	var new_damage: float = player.bullet_damage + get_damage_we_will_add(player, cardData)
	return str(description, "Bullet damage increased from ", int(round(player.bullet_damage)), " to ", int(round(new_damage)))

func is_possible(player: Player, cardData: CardData) -> bool:
	return player.bullet_damage + get_damage_we_will_add(player, cardData) < 1.1 * player.get_parent().get_mob_average_health()

func apply_card(player: Player):
	player.bullet_damage += get_damage_we_will_add(player, self)
