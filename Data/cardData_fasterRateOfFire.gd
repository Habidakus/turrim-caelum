extends CardData

var newBulletsPerMinute;

func is_possible(_player: Player, _cardData: CardData) -> bool:
	return newBulletsPerMinute < 301

func initialize_for_purchase(player: Player, cardData: CardData):
	var currentBulletsPerMinute = 60 / player.rate_of_fire
	newBulletsPerMinute = (60 * (cardData.boonMultiple - 1) + currentBulletsPerMinute)

func get_description(_player: Player, _cardData: CardData) -> String:
	return str(description, "Increase to ", int(round(newBulletsPerMinute)), " bullets/minute")

func get_multiple(player: Player, _cardData: CardData) -> float:
	var currentBulletsPerMinute = 60 / player.rate_of_fire
	return newBulletsPerMinute / currentBulletsPerMinute
	
func apply_card(player: Player):
	player.rate_of_fire /= get_multiple(player, self)
