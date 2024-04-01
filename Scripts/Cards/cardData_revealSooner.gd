extends CardData

func initialize_for_purchase(worth : PlayerWorth):
	worth.showPathDist /= boonMultiple
	
func apply_card(player: Player):
	player.showPathDist /= boonMultiple
