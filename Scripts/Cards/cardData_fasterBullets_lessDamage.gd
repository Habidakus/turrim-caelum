extends CardData

func get_description(player: Player, cardData: CardData) -> String:
	var new_speed : float = player.bullet_speed + get_bullet_speed_we_will_add(player, cardData)
	var new_damage: float = player.bullet_damage - get_damage_we_will_remove(player, cardData)
	return str(description, "Bullet speed increase from ", int(round(player.bullet_speed)), " to ", int(round(new_speed)), ", bullet damage decreased from ", int(round(player.bullet_damage)), " to ", int(round(new_damage)))
	
func is_possible(player: Player, cardData: CardData) -> bool:
	var damageOk : bool = player.bullet_damage - get_damage_we_will_remove(player, cardData) < 1.1 * player.get_parent().get_mob_average_health()
	var new_speed : float = player.bullet_speed + get_bullet_speed_we_will_add(player, cardData)
	var speedOk : bool = new_speed > player.speed && new_speed <= 1000.0
	return damageOk && speedOk

func apply_card(player: Player):
	player.bullet_speed += get_bullet_speed_we_will_add(player, self)
	player.bullet_damage -= get_damage_we_will_remove(player, self)
