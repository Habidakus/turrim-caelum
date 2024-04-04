extends CardData

func does_change_player_charges() -> bool:
	return true

func initialize_for_purchase(worth : PlayerWorth):
	worth.tchotchkeCount += 1
	
func apply_card(player: Player):
	player.tchotchke = true
