extends CardData

var newBulletsPerMinute;

func is_possible(player: Player, cardData: CardData) -> bool:
	return get_multiple(player, cardData) * player.bullet_speed > player.speed

func initialize_for_purchase(_player: Player, _cardData: CardData):
	var currentBulletsPerMinute = 60 / _player.rate_of_fire
	newBulletsPerMinute = (60 * (_cardData.boonMultiple - 1) + currentBulletsPerMinute)

func get_description(_player: Player, _cardData: CardData) -> String:
	return str(description, "Increase to ", newBulletsPerMinute, " bullets/minute")

func get_multiple(_player: Player, _cardData: CardData) -> float:
	var currentBulletsPerMinute = 60 / _player.rate_of_fire
	return newBulletsPerMinute / currentBulletsPerMinute
