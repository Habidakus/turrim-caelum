extends CardData

func get_description(player: Player, cardData: CardData) -> String:
	var new_damage: float = player.bullet_damage + get_damage_we_will_add(player, cardData)
	var newRange : float =  player.bullet_range - get_decrease_to_bullet_range(player, cardData)
	var damageText : String = str("Bullet damage increased from ", int(round(player.bullet_damage)), " to ", int(round(new_damage)))
	var rangeText : String = str("range decreased from ", int(round(player.bullet_range)), " to ", int(round(newRange)))
	return str(description, damageText, ", ", rangeText)

func is_possible(player: Player, cardData: CardData) -> bool:
	var damageOk : bool = player.bullet_damage + get_damage_we_will_add(player, cardData) < 1.1 * player.get_parent().get_mob_average_health()
	var rangeOk : bool = get_increase_to_bullet_range(player, cardData) + player.bullet_range <= 1024
	return rangeOk && damageOk

func apply_card(player: Player):
	player.bullet_damage += get_damage_we_will_add(player, self)
	player.bullet_range -= get_decrease_to_bullet_range(player, self)
