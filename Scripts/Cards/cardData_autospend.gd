extends CardData

func initialize_for_purchase(worth : PlayerWorth):
	worth.autospendCount += 1
	
func apply_card(player: Player):
	player.autospend = true
