extends CardData

var newBulletsPerMinute;

func initialize_for_purchase(player: Player, cardData: CardData):
	var currentBulletsPerMinute = 60 / player.rate_of_fire
	newBulletsPerMinute = get_delta_decreased_rate_of_fire_per_minute(cardData) + currentBulletsPerMinute

func get_description(player: Player, cardData: CardData) -> String:
	var currentBulletsPerMinute = 60 / player.rate_of_fire
	var new_damage: float = player.bullet_damage + get_damage_we_will_add(player, cardData)
	var damageText : String = str("Bullet damage increased from ", int(round(player.bullet_damage)), " to ", int(round(new_damage)))
	var slowText : String = str(", Rate of fire decreased from ", int(round(currentBulletsPerMinute)) , " to ", int(round(newBulletsPerMinute)))
	return str(description, damageText, ", ", slowText)

func is_possible(player: Player, cardData: CardData) -> bool:
	var rateOfFireOk : bool = newBulletsPerMinute < 301
	var damageOk : bool = player.bullet_damage + get_damage_we_will_add(player, cardData) < 1.1 * player.get_parent().get_mob_average_health()
	return rateOfFireOk && damageOk

func apply_card(player: Player):
	player.bullet_damage += get_damage_we_will_add(player, self)
	player.rate_of_fire = newBulletsPerMinute / 60.0
